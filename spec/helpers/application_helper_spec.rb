require 'spec_helper'

describe ApplicationHelper do

  describe 'full_title' do
    it 'should include the page title' do
      full_title('foo') =~ /foo/
    end

    it 'should include the base title' do
      full_title('foo') =~ /^Ruby on Rails Tutorial Sample App/
    end

    it 'should not include the page title' do
      full_title('') =~ /\|/
    end
  end
end