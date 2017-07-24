
public class ShapedWindow : Gtk.Window {

  private Cairo.Surface event_mask=null;

    public ShapedWindow (Gtk.Application application) {
        Object (application: application,
                icon_name: "org.spheras.ekm4android",
                resizable: false,
                title: "ShapedWindow",
                decorated:false,
                app_paintable:true,
                height_request: 595,
                width_request: 500);

        skip_taskbar_hint = true;
        // skip_taskbar_hint determines whether the window gets an icon in the taskbar / dock
        create_mask();
        // Need to get the rgba colormap or transparency doesn't work.
        set_visual(screen.get_rgba_visual());
        // The expose event is what is called when we need to draw the window
    }

    construct {
        //set_keep_below (true);
        //always in the working area
        stick ();
    }

    private void create_mask() {
      try{
        var pixbuf=new Gdk.Pixbuf.from_resource("/org/spheras/ekm4android/android_robot.png");
        var surface=Gdk.cairo_surface_create_from_pixbuf(pixbuf,1,null);
        this.event_mask = surface;//new Cairo.ImageSurface.from_png("android_robot.png");
        input_shape_combine_region(Gdk.cairo_region_create_from_surface(event_mask));
        } catch (Error e) {
            warning ("%s\n", e.message);
        }
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

        ctx.set_source_surface(this.event_mask,0,0);
        ctx.paint();

        return true;
    }
}
