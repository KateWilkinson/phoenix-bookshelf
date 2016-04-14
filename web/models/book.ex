defmodule PhoenixBookshelf.Book do
  use PhoenixBookshelf.Web, :model
  use Timex

  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,    Record.extract(:xmlText,    from_lib: "xmerl/include/xmerl.hrl")

  schema "books" do
    field :title, :string
    field :isbn, :string
    field :image_url, :string

    timestamps
  end

  @required_fields ~w(isbn)
  @optional_fields ~w(title image_url)
  @access_key System.get_env("AWSAccessKeyId")
  @secret_key System.get_env("AWSSecretKey")
  @associate_tag System.get_env("AssociateTag")
  @isbn "9780091922344"

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:isbn, min: 10)
    |> validate_length(:isbn, max: 13)
    |> validate_format(:isbn, ~r/^[0-9]*$/)
    |> unique_constraint(:isbn, message: "ISBN has already been added")
  end

  def amazon_info(isbn) do
    response = HTTPotion.get(url(isbn))
    response.body
  end

  def get_attribute(attr, isbn) do
    amazon_info(isbn)
      |> remove_pound
      |> scan_text
      |> parse(attr)
  end

  def parse({ xml, _ }, attr) do
    [element] = :xmerl_xpath.string('/ItemLookupResponse/Items/Item[1]/ItemAttributes/#{attr}[1]', xml)
    [text] = xmlElement(element, :content)
    value = xmlText(text, :value)
  end

  def scan_text(text) do
    :xmerl_scan.string(String.to_char_list(text))
  end

  def remove_pound(xml) do
    String.replace(xml,"£","")
  end

  def url(isbn) do
    "http://webservices.amazon.co.uk/onca/xml?#{query_string(isbn)}"
      |> URI.parse
      |> timestamp_url
      |> sign_url
      |> String.Chars.to_string
  end

  def query_string(isbn) do
    %{
      "AWSAccessKeyId" => @access_key,
      "AssociateTag" => @associate_tag,
      "IdType" => "ISBN",
      "ItemId" => isbn,
      "Operation" => "ItemLookup",
      "ResponseGroup" => "ItemAttributes",
      "SearchIndex" => "Books",
      "Service" => "AWSECommerceService"
    } |> URI.encode_query
  end

  defp sign_url(url_parts) do
    signature = :crypto.hmac(:sha256, @secret_key, Enum.join(["GET", url_parts.host, url_parts.path, url_parts.query], "\n"))
      |> Base.encode64
    update_url url_parts, "Signature", signature
  end

  defp update_url(url_parts, key, value) do
    updated_query = url_parts.query
                        |> URI.decode_query
                        |> Map.put_new(key, value)
                        |> percent_encode_query
    Map.put url_parts, :query, updated_query
  end

  defp timestamp_url(url_parts) do
    { _, timestamp} = DateTime.universal |> Timex.format("{ISOz}")
    update_url url_parts, "Timestamp", timestamp
  end

  # see https://github.com/zachgarwood/elixir-amazon-product-advertising-client/blob/master/lib/amazon_product_advertising_client.ex
  defp pair({k, v}) do
    URI.encode(Kernel.to_string(k), &URI.char_unreserved?/1) <>
    "=" <> URI.encode(Kernel.to_string(v), &URI.char_unreserved?/1)
  end

  defp percent_encode_query(query_map) do
    Enum.map_join(query_map, "&", &pair/1)
  end
end
