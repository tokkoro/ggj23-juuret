using Godot;
using System;

public class LeafGfx : Line2D
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        int parts = 14;
        var positions = new Vector2[(parts + 1)];
        positions[0] = Vector2.Zero;
        for (int i = 0; i < parts; i++)
        {
            float t_n = (i + 1) / (float)parts;
            positions[i + 1] = new Vector2(t_n, 0);
            //positions[i + 1] = CurveTools.CubicBezier(x0, c0, c1, x1, t_n * t);
        }
        this.Points = positions;
    }

    public void SetParameters(float scale, Vector2 pos, float angle)
    {
        this.Scale = Vector2.One * scale * 5;
        this.Position = pos;
        this.RotationDegrees = angle;
    }
}
