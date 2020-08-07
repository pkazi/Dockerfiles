class Article < ApplicationRecord
    def is_available
      Time.now >= publish_on
    end
end
