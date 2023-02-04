using Godot;
using System;

public class RootGfx : Line2D
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {

    }

    //  // Called every frame. 'delta' is the elapsed time since the previous frame.
    //  public override void _Process(float delta)
    //  {
    //      
    //  }
    public void SetParameters(Vector2 x0, Vector2 x1, float w, Vector2 c0, Vector2 c1, float t)
    {
        int parts = 14;
        var positions = new Vector2[(parts + 1)];
        positions[0] = x0;
        for (int i = 0; i < parts; ++i)
        {
            float t_n = (i + 1) / (float)parts;
            // positions[i + 1] = x0.LinearInterpolate(x1, t);
            positions[i + 1] = CurveTools.CubicBezier(x0, c0, c1, x1, t_n * t);
        }

        this.Points = positions;
        this.Width = w;
    }

}
