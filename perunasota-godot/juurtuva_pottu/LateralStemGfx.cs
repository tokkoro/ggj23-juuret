using Godot;
using System;
using System.Collections.Generic;

public class LateralStemGfx : Line2D
{

    List<LeafGfx> leafGfxes = new List<LeafGfx>();

    public override void _Ready()
    {
        for (int i = 0; i < 30; ++i)
        {
            this.GenerateNewLeaf();
        }
        foreach (var l in this.leafGfxes)
        {
            l.SetParameters(0, Vector2.Zero, 0);
        }
    }


    public void SetParameters(Vector2 x0, Vector2 x1, float w, Vector2 c0, Vector2 c1, float t, Side side)
    {
        int parts = 14;
        var positions = new Vector2[(parts + 1)];
        positions[0] = x0;
        for (int i = 0; i < parts; ++i)
        {
            float t_n = (i + 1) / (float)parts;
            // positions[i + 1] = x0.LinearInterpolate(x1, t);
            positions[i + 1] = CurveTools.CubicBezier(x0, c0, c1, x1, t_n * t);
            // for each point add two leafs, but not first and last
            if (i % 2 == 1)
            {
                float leafT = Mathf.Clamp((t - 0.1f * (i - 1)) / 0.5f, 0, 1);
                this.leafGfxes[i - 1].SetParameters(leafT, positions[i + 1], side == Side.RIGHT ? -60 : 180 - 60);
                this.leafGfxes[parts + (i - 1)].SetParameters(leafT, positions[i + 1], side == Side.RIGHT ? 60 : 180 + 60);
            }

        }
        this.Points = positions;
        this.Width = w;

        // Animate leafs
        // 0-0.1 = to grow each

    }

    private void GenerateNewLeaf()
    {
        PackedScene leafBase = ResourceLoader.Load<PackedScene>("res://juurtuva_pottu/LeafGfx.tscn");
        Node newNode = leafBase.Instance();
        AddChild(newNode);
        this.leafGfxes.Add(newNode as LeafGfx);
    }

}
