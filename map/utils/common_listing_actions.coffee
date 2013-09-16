'use strict'

define ['common/ag-utils', 'common/virtual-tour'],(utils, virtualTour) ->

  setPhotoPlusSlideShow = ->
    $('.photoplus').photoplus()
    _warehousePhotoTracking()

  initVirtualTours = ->
    $('.link_icon_virtual').each -> virtualTour.setupTour $(this)

  _warehousePhotoTracking = ->
    $('.scrollingHotSpotLeft, .scrollingHotSpotRight').bind 'click', (e) =>
      listingId = $(e.target).closest('.column1').find('a.link_icon_photos').attr 'data-listingid'
      $imageContainer = $(e.target).closest('.column1').find '.scrollableArea'
      _setListingId $imageContainer, listingId
      WH.fire
        sg: 'scrollableArea'
        item: 'scrollablePhoto'
        type: 'click'
        listingId: listingId
    utils.slideshowTracking()

  _setListingId = (imageContainer, listingId) ->
    images = $(imageContainer).find 'img'
    $(images).each ->
      $(this).attr 'class', 'photo'
      $(this).attr 'data-listingid', listingId

  return {
    setPhotoPlusSlideShow: setPhotoPlusSlideShow,
    initVirtualTours: initVirtualTours
  }
