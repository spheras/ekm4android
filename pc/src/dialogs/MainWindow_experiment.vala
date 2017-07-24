
public class MainWindow : Gtk.Dialog {

  private EKM4Android.Services.ObjectManager object_manager;
  private Cairo.Surface event_mask=null;

    public MainWindow (Gtk.Application application) {
        Object (application: application,
                icon_name: "org.spheras.ekm4android",
                resizable: false,
                title: "EKM4Android",
                decorated:false,
                app_paintable:true,
                height_request: 595,
                width_request: 500);
        this.manage_bluetooth();


        skip_taskbar_hint = true;
        // skip_taskbar_hint determines whether the window gets an icon in the taskbar / dock
        create_mask();
        // Need to get the rgba colormap or transparency doesn't work.
        set_visual(screen.get_rgba_visual());
        // The expose event is what is called when we need to draw the window
        //draw.connect(on_expose);

    }

    construct {
        //set_keep_below (true);
        //always in the working area
        stick ();

        var title=new Gtk.Label (_("EKM4Android Beta"));
        title.set_line_wrap(true);
        title.set_yalign(0);
        title.set_max_width_chars (50);
        title.get_style_context ().add_class ("ekm4android_title");

        //the description of the window
        var strdesc=_("Select the Android device you want to control. Remember you must have EKM4Android enabled in your android device.");
        var strdescmarkup=_("Select the Android device you want to control. Remember you must have <a href=\"http://www.google.es\">EKM4Android</a> enabled in your android device.");
        var description=new Gtk.Label (strdesc);
        description.set_markup(strdescmarkup);
        description.set_line_wrap(true);
        description.set_yalign(0);
        description.set_max_width_chars (50);
        description.get_style_context ().add_class ("ekm4android_description");

        //The listbox to show the bluetooth devices
        var list_box = new Gtk.ListBox();
        list_box.set_selection_mode(Gtk.SelectionMode.SINGLE);
        list_box.set_size_request(50,200);
        list_box.set_margin_top(10);
        list_box.get_style_context ().add_class ("ekm4android_listbox");

        var grid = new Gtk.Grid ();
        grid.get_style_context ().add_class ("ekm4android_grid");
        grid.column_spacing = 12;
        grid.margin_bottom = 6;
        grid.margin_end = 18;
        grid.margin_start = 18;
        grid.attach (title, 0, 0, 1, 1);
        grid.attach (description, 0, 1, 1, 1);
        grid.attach (list_box,0,2,1,1);

        //we add the content
        /* for windows
        this.add(grid);
        this.show_all();
        */

        var content_box = get_content_area () as Gtk.Box;
        content_box.border_width = 0;
        content_box.add(grid);
        content_box.show_all ();
    }

    /**
    * open the bluetooth settings (only works in elementary os?)
    */
    private void show_settings () {
        try {
            Gtk.show_uri (null, "settings://network/bluetooth", Gdk.CURRENT_TIME);
        } catch (Error e) {
            warning ("%s\n", e.message);
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
        var devices=this.object_manager.get_devices().to_array ();
        debug("number of devices found:%i",devices.length);
        for(int i=0;i<devices.length;i++) {
          var device=devices[i];
          debug("device {name:'%s', alias:'%s'", device.name, device.alias );
        }
    }


            private void create_mask() {
              var pixbuf=new Gdk.Pixbuf.from_resource("/org/spheras/ekm4android/android_robot.png");
              var surface=Gdk.cairo_surface_create_from_pixbuf(pixbuf,1,null);
              /*
              var format = (pixbuf.get_has_alpha () ? Cairo.Format.ARGB32 : Cairo.Format.RGB24);
              var width = pixbuf.get_width ();
              var height = pixbuf.get_height ();
              var surface= Gdk.cairo_image_surface_create (format, width, height);
              var surfaceContext=cairo.Context(surface)              ;
              Gdk.cairo_set_source_pixbuf (surfaceContext, pixbuf, 0, 0);
              surfaceContext.paint();
              */
              this.event_mask = surface;//new Cairo.ImageSurface.from_png("android_robot.png");
              input_shape_combine_region(Gdk.cairo_region_create_from_surface(event_mask));
            }


            public override bool draw (Cairo.Context cr) {
                on_expose(cr);
                base.draw (cr);
                return true;
            }

            /**
             * Actual drawing takes place within this method
             **/
            private bool on_expose (Cairo.Context ctx) {
                    // This makes the current color transparent (a = 0.0)
                    ctx.set_source_rgba(1.0,1.0,1.0,0.0);

                    // Paint the entire window transparent to start with.
                    ctx.set_operator(Cairo.Operator.SOURCE);
                    ctx.paint();

                    /*
                    var pixbuf=new Gdk.Pixbuf.from_resource("/org/spheras/ekm4android/android_robot.png");
                    Gdk.cairo_set_source_pixbuf (ctx, pixbuf, 0, 0);
                    ctx.paint();
                    */

                    ctx.set_source_surface(this.event_mask,0,0);
                    ctx.paint();

                    return true;
            }
}
