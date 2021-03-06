# frozen_string_literal: true

require 'csv'

class CampaignArticlesCsvBuilder
  include ArticleHelper

  def initialize(campaign)
    @campaign = campaign
  end

  CSV_HEADERS = %w[
    article_title
    ores_before
    ores_after
    bytes_added
    article_url
    course
  ].freeze

  def articles_to_csv
    csv_data = [CSV_HEADERS]
    @campaign.courses.each do |course|
      course.articles_courses.each do |articles_course|
        csv_data << article_row(articles_course, course)
      end
    end

    CSV.generate { |csv| csv_data.uniq.each { |line| csv << line } }
  end

  def article_row(articles_course, course)
    article = articles_course.article
    ordered_revisions = articles_course.all_revisions.order('date ASC')
    first_revision = ordered_revisions.first
    last_revision = ordered_revisions.last
    [
      article.title,
      first_revision&.wp10_previous || 0.0,
      last_revision&.wp10 || 0.0,
      articles_course.character_sum,
      article_url(article),
      course.slug
    ]
  end
end
