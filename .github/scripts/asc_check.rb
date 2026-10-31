#!/usr/bin/env ruby
# App Store Connect API kaliti yaroqliligini tekshiradi (maxfiy qiymatlarni CHIQARMAYDI).
require 'openssl'; require 'json'; require 'base64'; require 'net/http'; require 'uri'
kid = ENV.fetch('ASC_KEY_ID'); iss = ENV.fetch('ASC_ISSUER_ID')
key = OpenSSL::PKey.read(File.read(File.join(Dir.home, ".appstoreconnect/private_keys/AuthKey_#{kid}.p8")))
b64 = ->(s) { Base64.urlsafe_encode64(s, padding: false) }
head = b64.call({ alg: 'ES256', kid: kid, typ: 'JWT' }.to_json)
body = b64.call({ iss: iss, iat: Time.now.to_i, exp: Time.now.to_i + 600, aud: 'appstoreconnect-v1' }.to_json)
der = key.sign(OpenSSL::Digest::SHA256.new, "#{head}.#{body}")
r, s = OpenSSL::ASN1.decode(der).value.map { |i| i.value.to_s(2).rjust(32, "\0")[-32..] }
jwt = "#{head}.#{body}.#{b64.call(r + s)}"
uri = URI('https://api.appstoreconnect.apple.com/v1/apps?limit=5')
res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.get(uri, 'Authorization' => "Bearer #{jwt}") }
puts "ASC API javobi: HTTP #{res.code}"
data = (JSON.parse(res.body) rescue {})
(data['errors'] || []).each { |e| puts "  xato: #{e['code']} - #{e['title']}: #{e['detail']}" }
if res.code == '200'
  apps = (data['data'] || []).map { |a| "#{a.dig('attributes', 'name')} (#{a.dig('attributes', 'bundleId')})" }
  puts "  ilovalar: #{apps.empty? ? 'hali yo\'q' : apps.join(', ')}"
else
  exit 1
end
