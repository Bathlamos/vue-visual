###
Configuration related to the relationship between the component and the viewport
###

# Deps
throttle = require 'lodash/throttle'
fireWhenReady = require './utils/fire-when-ready'
require './utils/custom-event'

# Make a single window resize listener
resizingVms = []
resizeAllVms = -> vm.handleWindowResizeThrottled() for vm in resizingVms
window?.addEventListener 'resize', -> resizeAllVms()
fireWhenReady resizeAllVms

# The mixin
module.exports =

	##############################################################################
	props:
		offset:         { type: [Number, String, Object], default: 0 }
		offsetPoster:   [Number, String, Object]
		offsetImage:    [Number, String, Object]
		offsetVideo:    [Number, String, Object]

	##############################################################################
	data: ->

		# Measure dimensions
		windowWidth:       null
		containerWidth:    null
		containerHeight:   null

		# Whether asset is in viewport given offsets
		posterInViewport: null
		imageInViewport:  null
		videoInViewport:  null

	##############################################################################
	mounted: ->

		# Start listening to window resizing
		if @shouldWatchComponentSize
			resizingVms.push this
			@handleWindowResize()
			@handleWindowResizeThrottled = throttle @handleWindowResize, 100

	##############################################################################
	destroyed: ->

		# Remove resizing reference
		resizingVms.splice(resizingVms.indexOf(this), 1)

	##############################################################################
	methods:

		# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# Container sizing

		# Update the internal measurement of the window size
		handleWindowResize: ->
			@windowWidth = window.innerWidth
			@updateContainerSize() if @shouldWatchComponentSize

		# Update the container size.  Note, if there is no video specified we don't
		# need to know the height.  This saves some CPU:
		# https://jsperf.com/does-reading-one-offset-improve-performance
		updateContainerSize: ->
			@containerWidth = @$el.offsetWidth
			@containerHeight = @$el.offsetHeight if @video
