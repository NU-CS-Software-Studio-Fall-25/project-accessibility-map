# frozen_string_literal: true

json.array!(@reviews, partial: "reviews/review", as: :review)
