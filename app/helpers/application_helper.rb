# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def day_from_now(time)
    return '' if time.nil?
    today?(time) || tomorrow?(time) || this_week?(time) || next_week?(time)
  end

  def today?(time)
    today = Time.now.getlocal
    t(:today) if today.to_date == time.to_date
  end

  def tomorrow?(time)
    tomorrow = 1.day.from_now
    t(:tomorrow) if tomorrow.to_date == time.to_date
  end

  def this_week?(time)
    week = Time.now.getlocal.beginning_of_week.to_date
    t(:week) if week == time.beginning_of_week.to_date
  end

  def next_week?(time)
    week = 1.week.from_now.to_date
    t(:next_week) if week == time.beginning_of_week.to_date
  end
end

