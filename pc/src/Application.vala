/*
* Copyright (c) 2017 José Amuedo (https://github.com/spheras)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class EKM4AndroidApp : Gtk.Application {

    public EKM4AndroidApp () {
        Object (application_id: "org.spheras.ekm4android",
        flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        //only one app at a time
        if (get_windows().length () > 0) {
            get_windows().data.present ();
            return;
        }

        var app_window = new MainWindow (this);
        add_window(app_window);
        //app_window.show ();

        //css styles
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("org/spheras/ekm4android/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        //quit action
        var quit_action = new SimpleAction ("quit", null);
        add_action (quit_action);
        add_accelerator ("<Control>q", "app.quit", null);
        quit_action.activate.connect (() => {
            if (app_window != null) {
                app_window.destroy ();
            }
        });
    }

    public static int main (string[] args) {
        var app = new EKM4AndroidApp ();
        return app.run (args);
    }
}
