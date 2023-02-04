using Godot;
using System;

public class StolonGfx : Line2D
{

    private Sprite newPotato;

    private float rScale;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        this.newPotato = GetNode<Sprite>("./Uus_pottu");
        this.newPotato.RotationDegrees = GD.Randf() * 360;
        rScale = (float)GD.RandRange(0.37, 1.3);
    }

    //  // Called every frame. 'delta' is the elapsed time since the previous frame.
    //  public override void _Process(float delta)
    //  {
    //      
    //  }

    // potato
    public void SetParameters(Vector2 x0, Vector2 x1, float w, float potatoSize, Vector2 c0, Vector2 c1, float t)
    {
        int parts = 14;
        var positions = new Vector2[(parts + 1)];
        positions[0] = x0;
        for (int i = 0; i < parts; i++)
        {
            float t_n = (i + 1) / (float)parts;
            //positions[i + 1] = x0.LinearInterpolate(x1, t);
            positions[i + 1] = CurveTools.CubicBezier(x0, c0, c1, x1, t_n * t);
        }

        this.Points = positions;
        this.Width = w;
        this.newPotato.Scale = new Vector2(0.025f, 0.025f) * potatoSize * rScale;
        this.newPotato.Position = x1;
    }

}
