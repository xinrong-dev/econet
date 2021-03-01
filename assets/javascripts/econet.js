$(document).ready(function () {

  if ($('.controller-issues.action-new #issue_due_date').length) {

    const afterThreeDaysFromNow = new Date().getTime() + 3 * 24 * 60 * 60 * 1000
    let dueDate = afterThreeDaysFromNow
    if (new Date(afterThreeDaysFromNow).getDay() === 6) {
      dueDate = afterThreeDaysFromNow + 2 * 24 * 60 * 60 * 1000
    } else if (new Date(afterThreeDaysFromNow).getDay() === 0) {
      dueDate = afterThreeDaysFromNow + 24 * 60 * 60 * 1000
    }

    const d = new Date(dueDate);
    let month = (d.getMonth() + 1).toString()
    let day = d.getDate().toString()
    const year = d.getFullYear()

    if (month.length < 2) {
      month = '0' + month
    }
    if (day.length < 2) {
      day = '0' + day
    }

    $('.controller-issues.action-new #issue_due_date').val([year, month, day].join('-'))
  }

  if ($('.controller-issues.action-new #issue_subject').length && $('.controller-issues.action-new span:contains("お客様名")').length) {
    $('.controller-issues.action-new #issue_subject').on('blur', function () {
      $('.controller-issues.action-new span:contains("お客様名")').parent().siblings('input').val($(this).val())
    })
  }

  if ($('.controller-issues.action-show .cf_34.attribute').length > 0) {
    const link = $('.controller-issues.action-show .cf_33.attribute .value').text()
    $('.controller-issues.action-show .cf_33.attribute .value').html(`<a class="external" href="${link}">${link}</a>"`)
  }

})
