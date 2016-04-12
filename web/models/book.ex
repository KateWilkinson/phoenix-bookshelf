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
  @test_isbn "9780091922344"

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
    response = HTTPotion.get ...
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
    IO.inspect to_string(value)
  end

  def scan_text(text) do
    :xmerl_scan.string(String.to_char_list(text))
  end

  def remove_pound(xml) do
    String.replace(xml,"£","")
  end
end

defp sign_request do
  string_to_sign = "GET\nwebservices.amazon.com\n/onca/xml\n" <> "AWSAccessKeyId=#{@access_key}&AssociateTag=#{@associate_tag}&ItemId=0679722769&Operation=ItemLookup&ResponseGroup=ItemAttributes&Service=AWSECommerceService&Timestamp=#{PUT TIMESTAMP HERE}&Version=2013-08-01"
  :crypto.hmac(:sha256, 'ThisIsMySecretAccessKey', request)
end
