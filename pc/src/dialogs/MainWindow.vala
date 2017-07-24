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

/**
* Main Window of the application to configure and connect with the device.
*/
public class MainWindow : Gtk.Window {

    private EKM4Android.Services.ObjectManager object_manager;
    private Gtk.ListBox list_devices;
    private Gtk.Button button_connect;

    public MainWindow (Gtk.Application application) {
        Object (application: application,
                icon_name: "org.spheras.ekm4android",
                resizable: false,
                title: "EKM4Android",
                decorated:true,
                height_request: 520,
                width_request: 500);
    }

    construct {
        this.set_has_resize_grip(false);
        this.get_style_context ().add_class ("ekm4android_mainwindow");
        this.set_border_width (0);
        this.window_position = Gtk.WindowPosition.CENTER;
        //set_keep_below (true);
        //always in the working area
        //stick ();

        //the description of the window
        var strdesc=_("Select the Android device you want to control. Remember you must have EKM4Android enabled in your android smartphone.");
        var strdescmarkup=_("Select the Android device you want to control. Remember you must have <a href=\"http://www.google.es\">EKM4Android</a> enabled in your android smartphone.");
        var description=new Gtk.Label (strdesc);
        description.set_markup(strdescmarkup);
        description.set_line_wrap(true);
        description.set_yalign(0);
        description.margin_bottom = 6;
        description.margin_end = 18;
        description.margin_start = 18;
        description.set_max_width_chars (50);
        description.get_style_context ().add_class ("ekm4android_description");

        //The listbox to show the bluetooth devices
        var list_cont = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        list_cont.set_margin_top(10);
        list_cont.get_style_context ().add_class ("ekm4android_list_cont");
        list_cont.set_size_request(50,200);
            var scroll = new Gtk.ScrolledWindow (null, null);
            scroll.set_size_request(50,200);
            scroll.get_style_context().set_junction_sides(Gtk.JunctionSides.BOTTOM);
            scroll.get_style_context ().add_class ("ekm4android_scroll");

                this.list_devices = new Gtk.ListBox();
                this.list_devices.row_selected.connect (on_row_selected);
                this.list_devices.set_selection_mode(Gtk.SelectionMode.SINGLE);
                this.list_devices.get_style_context ().add_class ("ekm4android_listdevices");

                var element1=new Gtk.Label ("hola prueba");
                list_devices.add(element1);
                var element2=new Gtk.Label ("adios prueba");
                list_devices.add(element2);

            scroll.add(this.list_devices);
        list_cont.pack_start (scroll,true,true);

        var button_cont=new Gtk.Box(Gtk.Orientation.HORIZONTAL,2);
        button_cont.margin=10;
        button_cont.spacing=20;
            this.button_connect=new Gtk.Button.with_label(_("Connect"));
            button_connect.set_sensitive(false);
            button_connect.clicked.connect(this.on_connect);
            var button_settings=new Gtk.Button.with_label(_("Settings"));
            button_settings.clicked.connect (this.show_settings);
        button_cont.pack_start(button_connect,true,true);
        button_cont.pack_end(button_settings,true,true);

        var grid = new Gtk.Grid ();
        grid.get_style_context ().add_class ("ekm4android_grid");
        grid.column_spacing = 12;
        grid.attach (description, 0, 0, 1, 1);
        grid.attach (list_cont,0,1,1,1);
        grid.attach(button_cont,0,2,1,1);

        //we add the content
        add(grid);
        show_all();

        this.manage_bluetooth();
    }

    /**
    * open the bluetooth settings/wizard
    */
    private void show_settings () {
        /*
        try {
            Gtk.show_uri (null, "settings://network/bluetooth", Gdk.CURRENT_TIME);
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
        */
        try {
            var appinfo = AppInfo.create_from_commandline ("bluetooth-wizard", null, AppInfoCreateFlags.SUPPORTS_URIS);
            appinfo.launch_uris (null, null);
        } catch (Error e) {
            warning (e.message);
        }
    }

   /**
    * start the management for the Bluetooth adapters, and discovering devices
    */
    private void manage_bluetooth(){
      //the Bluetooth Manager object
      this.object_manager = new EKM4Android.Services.ObjectManager ();

      //???
      if (object_manager.has_object) {
          object_manager.set_last_state ();
      }
      this.object_manager.notify["has-object"].connect (() => {
          if (this.object_manager.has_object) {
              this.object_manager.set_last_state ();
          }
      });

      //when an adapter is found, we foce the discovering devices
      this.object_manager.adapter_added.connect( (adapter) => {
        debug("Bluetooth Adapter Discovered! (forcing discovering devices)");
        try {
            adapter.start_discovery();
            this.device_refresh();
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
      });
      this.object_manager.adapter_removed.connect( (adapter) => {
        this.device_refresh();
      });


      //lets listen to discovered devices
      this.object_manager.device_added.connect( (device) => {
          debug("Bluetooth Device Discovered!");
          this.device_refresh();
      });
      this.object_manager.device_removed.connect( (device) => {
          debug("Bluetooth Device Removed!");
          this.device_refresh();
      });

      debug ("Bluetooth Manager Started");
    }

    /**
    * Devices detected has changed. We need to refresh the info.
    */
    private void device_refresh(){
        //cleaning the listbox
        this.list_devices.foreach ((item) => {
                this.list_devices.remove (item);
        });

        //refreshing the info
        var devices=this.object_manager.get_devices().to_array ();
        debug("number of devices found:%i",devices.length);
        for(int i=0;i<devices.length;i++) {
            var device=devices[i];

            //Creating the row widgets
            var row=new Gtk.ListBoxRow();
                var container=new Gtk.Grid();
                container.margin_top=5;
                container.margin_bottom=5;
                container.margin_left=10;
                container.column_spacing = 6;
                container.orientation = Gtk.Orientation.HORIZONTAL;
                    var image = new Gtk.Image.from_icon_name (device.icon, Gtk.IconSize.DND);
                    var element=new Gtk.Label ( device.alias );
                    element.ellipsize = Pango.EllipsizeMode.END;
                    element.xalign=0;
                    element.get_style_context ().add_class ("ekm4android_device");
                    element.expand=true;
                container.attach (image, 0, 0, 1, 1);
                container.attach (element, 1, 0, 1, 1);
            row.add(container);
            this.list_devices.add(row);

          debug("device {name:'%s', alias:'%s'", device.name, device.alias );
        }
        this.list_devices.show_all();
    }

    /**
    * when a device has been selected event
    */
    private void on_row_selected (){
        this.button_connect.set_sensitive(true);
    }

    private void on_connect(){
        debug("poniendo el indicador");

        var elind=new EKM4Android.Indicator(false);

        /*
        var indicator = new AppIndicator.Indicator("win.title", "office-address-book", AppIndicator.IndicatorCategory.APPLICATION_STATUS);
        indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);
        var menu = new Gtk.Menu();
        var item = new Gtk.MenuItem.with_label("Añadir nuevo contacto");
        item.activate.connect(() => {
        //indicator.set_status(IndicatorStatus.ATTENTION);
        //CrearContacto();
        });
        item.show();
        menu.append(item);

        item = new Gtk.MenuItem.with_label("Borrar contacto");
        item.show();
        item.activate.connect(() => {
        //indicator.set_status(IndicatorStatus.ATTENTION);
        //BorrarContacto();
        });
        menu.append(item);
        indicator.set_menu(menu);
        indicator.set_title ("prueba");
        indicator.set_icon_full ("icon", "icon");
        */

        debug("fin poniendo el indicador");
    }
}
