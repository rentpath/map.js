jquery-leadservice
==================

There are separate major versions of this module that correspond
to the service API version.

In other words, the 1.x.x version of this module should be used
with API v1, and the 2.x.x version should be used with API v2.

Mobile Web Apps
===============

Version v2.3+

On mobile devices, it is not always desirable to load forms via ajax. By rendering the form inline and passing { disable_ajax: true } via lead_service form_params, you can boost your mobile web apps performance by limiting requests.
