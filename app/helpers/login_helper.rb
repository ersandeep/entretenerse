module LoginHelper
  def title
    title = ''
    if params[:date] && ['today', 'tomorrow', 'week', 'weekend', 'month'].include?(params[:date])
      title += t(params[:date])
    else
      date = Time.parse(params[:date]) rescue Time.now
      day = day_from_now(date)
      title += day + ', ' unless day.blank?
      title += I18n.localize(date, :format => :title)
    end
    title = @category.value.capitalize + ' ' + title unless @category.blank?
    title
  end
end
