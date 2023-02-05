using Godot;
using System;

public class SubRootGfx : Line2D
{
    public override void _Ready()
    {
        int parts = 14;
        var positions = new Vector2[(parts + 1)];
        positions[0] = Vector2.Zero;
        for (int i = 0; i < parts; i++)
        {
            float t_n = (i + 1) / (float)parts;
            positions[i + 1] = new Vector2(t_n * 5, 0);
            //positions[i + 1] = CurveTools.CubicBezier(x0, c0, c1, x1, t_n * t);
        }
        this.Points = positions;
        this.EndCapMode = LineCapMode.Round;
    }

    public void SetParameters(float scale, Vector2 pos, float angle)
    {
        this.Width = 0.1f * scale;

        int parts = 14;
        var positions = new Vector2[(parts + 1)];
        positions[0] = Vector2.Zero;

        for (int i = 0; i < parts; i++)
        {
            float t_n = (i + 1) / (float)parts;
            positions[i + 1] = new Vector2(t_n * 2 * scale, 0);
        }
        this.Points = positions;
        this.Position = pos;
        this.RotationDegrees = angle;
    }
}
