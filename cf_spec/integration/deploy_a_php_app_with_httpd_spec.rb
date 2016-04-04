$: << 'cf_spec'
require 'cf_spec_helper'

describe 'CF PHP Buildpack' do

  let(:browser) { Machete::Browser.new(@app) }
  before(:context) do
    @app = Machete.deploy_app(
      'php_app_using_httpd',
      {env: {'COMPOSER_GITHUB_OAUTH_TOKEN' => ENV['COMPOSER_GITHUB_OAUTH_TOKEN']}}
    )
  end
  after(:context) do
    Machete::CF::DeleteApp.new.execute(@app)
  end

  context 'deploying a basic PHP app using httpd as the webserver' do
    it 'compiles and starts the app' do
      expect(@app).to be_running
    end

    it 'shows the current buildpack version for useful info' do
      expect(@app).to have_logged "-------> Buildpack version #{File.read(File.expand_path('../../../VERSION', __FILE__)).chomp}"
    end

    it 'installs httpd, the request web server' do
      expect(@app).to have_logged 'Installing HTTPD'
    end

    it 'the root endpoint renders a dynamic message' do
      browser.visit_path('/')
      expect(browser).to have_body('PHP Version')
    end

    it 'has compression enabled by default' do
      app_uri = browser.base_url
      curl_result = `curl -I -v -H "Accept-Encoding: gzip,deflate" #{app_uri}`
      expect(curl_result).to include("Content-Encoding: gzip")
    end

    context 'in offline mode', :cached do
      specify do
        expect(@app).not_to have_internet_traffic
      end
    end
  end
end

