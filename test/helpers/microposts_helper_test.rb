require 'test_helper'

class MicropostsHelperTest < ActionView::TestCase
  include MicropostsHelper

  test 'url validation should accept valid url' do
    valid_urls = %w[
      http://google.com https://google.com
      https://google.com/ https://google.com/some/path
      https://mails.google.com
    ]

    valid_urls.each do |valid_url|
      assert url?(valid_url)
    end
  end

  test 'url validation should accept valid url with tag and parameters' do
    valid_urls = %w[
      http://google.com#some_tag
      https://google.com?some=param&other=param
      https://google.com/some/path?some=param123&other=param456#ANY_OTHER_TAG789
    ]

    valid_urls.each do |valid_url|
      assert url?(valid_url)
    end
  end

  test 'url validation should not accept invalid url' do
    invalid_urls = %w[
      http:://google.com https:/google.com
      https://googlecom/ https://GOOGLE.COM
    ]

    invalid_urls.each do |invalid_url|
      assert_not url?(invalid_url)
    end
  end
end
