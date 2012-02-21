Airpad is an iPad app to work with the awesome http://airbrake.io/ service.

It's not quite ready to be packaged into the app store yet, but feel free to fork and build your own copy; double points if you send patches back to me :).

NOTE: I'm not affiliated with Airbrake in any way, I just use their service.

FEATURES
========

* Listing all exceptions.
* Resolving exceptions (uses the same delightful slider as the main website).
* Per-exception occurance infographic (represents the first and last time an exception happens, along with its expected frequency, to easily allow seeing which problems are now resolved).
* Regexp searching on exception title.
* Filtering by "project".
* Showing the backtrace.
* Showing the exception parameters.
* Opening the airbrake page for an exception.


NOTE: if you want to clear out old "resolved" exceptions, you'll have to kill the App using the iPad task pane, and start it up again. (see TODOs).

TODO
====

* Currently AirPad's syncing logic is waay-overblown, and has terrible UX. (I used this app as an excuse to learn CoreData, I guess it shows :p).
* I want to somehow create a way to compare different occurances of the same exception.
* NEEDS MOAR TEXTURED BACKGROUNDS.

BUGS
====

* Sometimes the "resolved" tick mark doesn't appear in the sidebar, I think this happens more reliably if you switch to a different exception while the previous one is still being resolved.
* I'm sure there's still some invalid XML that the heuristic-fixer isn't catching.
* Sometimes a parameter field will appear empty, though large (implying that it's measured out space for a lot of text, but just isn't showing it).

Meta-Foo
========
Licensed under the MIT license, contributions and bug reports welcome :).

