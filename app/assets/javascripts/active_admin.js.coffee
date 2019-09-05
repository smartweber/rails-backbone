#= require active_admin/base
#= require activeadmin-sortable
#= require active_admin_datetimepicker
#= require tinymce
#= require jcrop/js/Jcrop

$(document).ready ->
  tinyMCE.init
    selector: 'textarea.tinymce'
    plugins: [
      'advlist autolink lists link image charmap print preview hr anchor pagebreak'
      'searchreplace wordcount visualblocks visualchars code fullscreen'
      'insertdatetime media nonbreaking save table contextmenu directionality'
      'emoticons template paste textcolor colorpicker textpattern imagetools uploadimage'
    ]
    toolbar1: 'insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image uploadimage'
    toolbar2: 'print preview media | forecolor backcolor emoticons'
    plugin_preview_width: 969
    image_advtab: true
    content_css: [
      '//www.tinymce.com/css/codepen.min.css'
    ]
    uploadimage_form_url: '/admin/admin_user_attachments'

  updateForm = (c) ->
    $('#thumbnail_x').val(c.x)
    $('#thumbnail_y').val(c.y)
    $('#thumbnail_w').val(c.w)
    $('#thumbnail_h').val(c.h)

  initializeJcrop = (locator) ->
    carouselBigImageWidth  = 598
    carouselBigImageHeight = 448

    $(locator).Jcrop {
      minSize: [carouselBigImageWidth, carouselBigImageHeight]
      aspectRatio: carouselBigImageWidth / carouselBigImageHeight
      onSelect: updateForm
      onChange: updateForm
    }, ->
      jcrop_api = this

  $("input.croppable-thumbnail").change ->
    changeImgLocator = "#jcrop_target"

    if @files and @files[0]
      FR = new FileReader

      FR.onload = (e) ->
        $(changeImgLocator).attr 'src', e.target.result

      FR.readAsDataURL @files[0]
      FR.onloadend = (e) ->
        initializeJcrop(changeImgLocator)
