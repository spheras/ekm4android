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
*
*/

public class EKM4Android.Indicator : Wingpanel.Indicator {
    private bool is_in_session = false;

    private EKM4Android.Widgets.PopoverWidget popover_widget;
    private EKM4Android.Widgets.DisplayWidget dynamic_icon;
    private EKM4Android.Services.ObjectManager object_manager;

    public Indicator (bool is_in_session) {

        Object (code_name: Wingpanel.Indicator.BLUETOOTH,
                display_name: _("EKM4Android"),
                description:_("Keyboard & Mouse for Android"));

        this.is_in_session = is_in_session;

        debug ("EKM4Android Indicator started");
    }

    public override Gtk.Widget get_display_widget () {
        if (dynamic_icon == null) {
            dynamic_icon = new EKM4Android.Widgets.DisplayWidget ();
        }

        return dynamic_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            popover_widget = new EKM4Android.Widgets.PopoverWidget (object_manager, is_in_session);
            popover_widget.request_close.connect (() => {
                close ();
            });
        }

        return popover_widget;
    }


    public override void opened () {
    }

    public override void closed () {
    }
}

public Wingpanel.Indicator get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating EKM4Android Indicator");
    var indicator = new EKM4Android.Indicator (server_type == Wingpanel.IndicatorManager.ServerType.SESSION);
    return indicator;
}
