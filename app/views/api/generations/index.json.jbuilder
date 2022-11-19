# frozen_string_literal: true

json.array! @generations, partial: "api/generations/generation", as: :generation
