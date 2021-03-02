$(document).ready(function () {

  if ($('.controller-issues.action-new #issue_due_date').length) {

    var afterThreeDaysFromNow = new Date().getTime() + 3 * 24 * 60 * 60 * 1000
    var dueDate = afterThreeDaysFromNow
    if (new Date(afterThreeDaysFromNow).getDay() === 6) {
      dueDate = afterThreeDaysFromNow + 2 * 24 * 60 * 60 * 1000
    } else if (new Date(afterThreeDaysFromNow).getDay() === 0) {
      dueDate = afterThreeDaysFromNow + 24 * 60 * 60 * 1000
    }

    var d = new Date(dueDate);
    var month = (d.getMonth() + 1).toString()
    var day = d.getDate().toString()
    var year = d.getFullYear()

    if (month.length < 2) {
      month = '0' + month
    }
    if (day.length < 2) {
      day = '0' + day
    }

    $('.controller-issues.action-new #issue_due_date').val([year, month, day].join('-'))
  }

  if (issueCustomerFieldID) {
    if ($('.controller-issues.action-new #issue_subject').length && $('.controller-issues.action-new #issue_custom_field_values_' + issueCustomerFieldID).length) {
      $('.controller-issues.action-new #issue_subject').on('blur', function () {
        $('.controller-issues.action-new #issue_custom_field_values_' + issueCustomerFieldID).val($(this).val())
      })
    }
  }

  if (issueSharepointFieldID) {
    if ($('.controller-issues.action-show .cf_' + issueSharepointFieldID + '.attribute').length > 0) {
      var link = $('.controller-issues.action-show .cf_' + issueSharepointFieldID + '.attribute .value').text()
      $('.controller-issues.action-show .cf_' + issueSharepointFieldID + '.attribute .value').html(`<a class="external" href="${link}">${link}</a>"`)
    }
  }

  if (projectSharepointFieldID) {
    if ($('.controller-projects.action-show .cf_' + projectSharepointFieldID).length > 0) {
      var text = $('.controller-projects.action-show .cf_' + projectSharepointFieldID + ' .label').text()
      $('.controller-projects.action-show .cf_' + projectSharepointFieldID + ' .label').remove()
      var link = $('.controller-projects.action-show .cf_' + projectSharepointFieldID).text()
      $('.controller-projects.action-show .cf_' + projectSharepointFieldID).html(`<span class="label">${text}</span><a class="external" href="${link}">${link}</a>"`)
    }
  }

})
