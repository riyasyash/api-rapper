WrapperGenerator.config do

  host_url "http://google.com"
  base_headers({"content-type" => "application/json"})

  endpoint "ename", "eurl" do |e|
    e.method "POST"
    e.attrs [:a1, :b1]
    e.response_attrs [:a,:b]
  end

end
