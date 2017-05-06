 $(document).ready(function() {
            $('#image-gallery').lightSlider({
                     item: 1,
                     autoWidth: false,
                     slideMove: 1, // slidemove will be 1 if loop is true
                     slideMargin: 0,

                     addClass: '',
                     mode: "slide",
                     useCSS: true,
                     cssEasing: 'ease', //'cubic-bezier(0.25, 0, 0.25, 1)',//
                     easing: 'linear', //'for jquery animation',////

                     speed: 1000, //ms'
                     auto: true,
                     loop: true,
                     slideEndAnimation: false,
                     pause: 5000,

                     keyPress: true,
                     controls: true,
                     prevHtml: '',
                     nextHtml: '',

                     rtl:false,           // Change direction to right-to-left
                     adaptiveHeight:true, // Dynamically adjust slider height based on each slide's height

                     vertical:false,
                     verticalHeight: 100,
                     vThumbWidth:50,

                  // thumbItem: 10,
                     pager: true,
                     gallery: true,
                     galleryMargin: 0,   // Spacing between gallery and slide
                     thumbMargin: 5,     // Spacing between each thumbnails
                     currentPagerPosition: 'left', //must be left (not center) so that it scrolls automatically

                     enableTouch:true,
                     enableDrag:true,
                     freeMove:false,
                     swipeThreshold: 0,   // ??????????

                     responsive : [],

                onSliderLoad: function() {
                    $('#image-gallery').removeClass('cS-hidden');
                }
            });
		});