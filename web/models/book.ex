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

  def amazon_info do
    response = HTTPotion.get(sign_request(url))
    response.body
  end

  def get_attribute(attr) do
    amazon_info
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

  def sign_request(url) do
    url_parts = URI.parse(url)
    request = "GET\n#{url_parts.host}\n#{url_parts.path}\n#{url_parts.query}"
    signature = :crypto.hmac(:sha256, @secret_key, request) |> Base.encode16
    IO.inspect signature
    "#{url}&Signature=#{signature}"
  end

  def timestamp do
    date = DateTime.universal
    { _, timestamp} = Timex.format(date, "{ISOz}")
    URI.encode(timestamp, &URI.char_unreserved?/1)
  end

  def url do
    "http://webservices.amazon.co.uk/onca/xml?AWSAccessKeyId=#{@access_key}&AssociateTag=#{@associate_tag}&IdType=ISBN&ItemId=#{@isbn}&Operation=ItemLookup&ResponseGroup=ItemAttributes&SearchIndex=Books&Service=AWSECommerceService&Timestamp=#{timestamp}&Version=2013-08-01"
  end
end
