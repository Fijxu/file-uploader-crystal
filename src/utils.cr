module Utils
  extend self

  # Thanks crystal community
  # https://forum.crystal-lang.org/t/is-this-a-good-way-to-generate-a-random-string/6986/6
  def random_string(len) : String
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    String.new(len) do |bytes|
      bytes.to_slice(len).fill { chars.to_slice.sample }
      {len, len}
    end
  end
end
