using Godot;
using System;
using System.Collections.Generic;

public class Pottu : Node2D
{
    private Seed? seed;
    private Stem stem;
    private List<Root> roots = new List<Root>();
    private List<Stolon> stolons = new List<Stolon>();

    private List<bool[]> rootSpawnHeights = new List<bool[]>();
    private List<bool[]> lateralStemSpawnHeights = new List<bool[]>();


    private float totalTime = 0;

    private List<LateralStem> lateralStems = new List<LateralStem>();

    private Vector2 groundHitPosition;
    private Vector2 targetPos;

    // GFX childs:
    private StemGfx stemGfx;
    private List<RootGfx> rootGfxs = new List<RootGfx>();
    private List<StolonGfx> stolonGfxs = new List<StolonGfx>();
    private List<LateralStemGfx> lateralStemGfxs = new List<LateralStemGfx>();

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        // find children
        this.stemGfx = this.GetNode<StemGfx>("./Stem");
        this.stemGfx.SetParameters(Vector2.Zero, Vector2.Zero, 1, Vector2.Zero, Vector2.Zero, 0);
        // test code
        this.Initalize();
        // this.totalTime = 1;
        this.UpdatePotato();
        GD.Print("Juurtuva pottu is _Ready " + this.Position);
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
        this.totalTime += delta;
        this.UpdatePotato();
    }

    public float DistanceToGround(Vector2 pos)
    {
        // returns negative when too high, so too negative, but positive when tool low
        float deep = groundHitPosition.y - targetPos.y;
        // GD.Print("Syvyys " + deep);
        return pos.y - (deep + 17); // 7 is bias to lower the ground point a bit as it's more desired
    }

    public void SetStartPosition(Vector2 position)
    {
        GD.Print("SetStartPosition " + position);

        groundHitPosition = position;
        targetPos = groundHitPosition + Vector2.Down * (45 + 10 * GD.Randf());
    }

    public void Initalize()
    {
        // generate potato's parts and parameters
        this.seed = new Seed()
        {
            startTime = this.totalTime,
            growStartDelay = 0.5f,
        };

        Vector2 stemStart = new Vector2((float)GD.RandRange(-5, 5), (float)GD.RandRange(-1, -5));
        Vector2 stemEnd = new Vector2((float)GD.RandRange(-10, 10), (float)GD.RandRange(-70, -90));

        this.stem = new Stem()
        {
            growPointOffset = stemStart, //new Vector2(1, -3),
            targetHeadPosition = stemEnd,
            groundBreakingPoint = Vector2.Up,
            controlPoint0 = stemStart + new Vector2((float)GD.RandRange(-5, 5), (float)GD.RandRange(-20, -5)),
            controlPoint1 = stemEnd + new Vector2((float)GD.RandRange(-5, 5), (float)GD.RandRange(20, 5)),
        };

        float maxLimit = 1;
        float minLimit = 0;
        int iterations = 10;
        while (--iterations > 0)
        {
            float midPoint = Mathf.Lerp(maxLimit, minLimit, 0.5f);
            Vector2 pos = CurveTools.CubicBezier(stem.growPointOffset, stem.controlPoint0, stem.controlPoint1, stem.targetHeadPosition, midPoint);
            float score = DistanceToGround(pos);
            if (score > 0)
            {
                minLimit = midPoint;
            }
            else
            {
                maxLimit = midPoint;
            }
            // GD.Print("Find ground max" + maxLimit + " min " + minLimit);
        }

        this.stem.groundBreakingPoint = CurveTools.CubicBezier(stemStart, stem.controlPoint0, stem.controlPoint1, stemEnd, minLimit);
    }

    // Potato simulation
    public void UpdatePotato()
    {
        if (!this.seed.HasValue)
        {
            return;
        }

        Seed seed = this.seed.Value;
        bool waitingForSeedToBeReady = this.totalTime < seed.startTime + seed.growStartDelay;
        float t_down = Mathf.Clamp((this.totalTime - seed.startTime) / seed.growStartDelay, 0, 1);
        this.Position = groundHitPosition.LinearInterpolate(this.targetPos, t_down);
        if (waitingForSeedToBeReady)
        {
            return;
        }
        float t = Mathf.Clamp((this.totalTime - seed.startTime - seed.growStartDelay) / 5f, 0, 1);

        // TODO: grow/animate seed

        // Stem
        // this.stem.headPoint = this.stem.growPointOffset.LinearInterpolate(this.stem.targetHeadPosition, t);
        this.stemGfx.SetParameters(this.stem.growPointOffset, this.stem.targetHeadPosition, Mathf.Lerp(1, 3, t), stem.controlPoint0, stem.controlPoint1, t);
        // Todo: generate roots and stolons as the stem grows
        // 20 slottia, vasemmalle ja oikealle 50%, mutta ei jos ala puolella jo on. 50-50 onko stolon vai root vai 
        // ajoitus 0-20 kasvu eli t=[0, 20/60]
        int rootHeight = 1 + Mathf.FloorToInt(9 * Mathf.Clamp(t * 3, 0, 1));
        while (rootHeight > rootSpawnHeights.Count)
        {
            if (rootSpawnHeights.Count == 0)
            {
                SpawnRootOrStolon(GD.Randf() > 0.5f, Side.LEFT, this.GetRootPosition(rootSpawnHeights.Count));
                SpawnRootOrStolon(GD.Randf() > 0.5f, Side.RIGHT, this.GetRootPosition(rootSpawnHeights.Count));
                rootSpawnHeights.Add(new bool[] { true, true });
                continue;
            }
            bool[] lastOne = rootSpawnHeights[rootSpawnHeights.Count - 1];
            bool[] result = new bool[2];
            for (int side = 0; side < 2; side++)
            {
                result[side] = false;
                if (!lastOne[side])
                {
                    bool doIt = GD.Randf() > 0.5f;
                    result[side] = doIt;
                    if (doIt)
                    {
                        SpawnRootOrStolon(GD.Randf() > 0.5f, side == 0 ? Side.LEFT : Side.RIGHT, this.GetRootPosition(rootSpawnHeights.Count));
                    }
                }
            }
            rootSpawnHeights.Add(result);
        }
        // update roots and stolons
        for (int i = 0; i < this.roots.Count; ++i)
        {
            Root r = this.roots[i];
            float r_t = Mathf.Clamp((this.totalTime - r.startTime) / r.duration, 0, 1);
            // Vector2 headPoint = r.growPointOffset.LinearInterpolate(r.targetHeadPosition, r_t);
            this.rootGfxs[i].SetParameters(r.growPointOffset, r.targetHeadPosition, Mathf.Lerp(0, 0.5f, r_t), r.controlPoint0, r.controlPoint1, r_t, r.side);
        }
        for (int i = 0; i < this.stolons.Count; ++i)
        {
            Stolon s = this.stolons[i];
            float s_t = Mathf.Clamp((this.totalTime - s.startTime) / s.duration, 0, 1);
            if (s_t > 0.99f)
            {
                s.ripe = true;
                this.stolons[i] = s;
            }
            // Vector2 headPoint = s.growPointOffset.LinearInterpolate(s.targetHeadPosition, Mathf.Clamp(s_t / 0.9f, 0, 1));
            this.stolonGfxs[i].SetParameters(s.growPointOffset, s.targetHeadPosition, Mathf.Lerp(0.1f, 0.75f, s_t), Mathf.Clamp((s_t - 0.9f) / 0.1f, 0, 1), s.controlPoint0, s.controlPoint1, Mathf.Clamp(s_t / 0.9f, 0, 1));
        }
        // Lateral stems
        int lateralHeight = -1 + Mathf.FloorToInt(11 * Mathf.Clamp((t - 0.3f) / 0.7f, 0, 1));
        while (lateralHeight > lateralStemSpawnHeights.Count)
        {
            bool[] lastOne = lateralStemSpawnHeights.Count > 0 ? lateralStemSpawnHeights[lateralStemSpawnHeights.Count - 1] : new bool[] { false, false };
            bool[] result = new bool[2];
            for (int side = 0; side < 2; side++)
            {
                result[side] = false;
                if (!lastOne[side])
                {
                    bool doIt = GD.Randf() > 0.5f;
                    result[side] = doIt;
                    if (doIt)
                    {
                        SpawnLateralStem(side == 0 ? Side.LEFT : Side.RIGHT, this.GetLateralStemPosition(lateralStemSpawnHeights.Count));
                    }
                }
            }
            lateralStemSpawnHeights.Add(result);
        }
        // update lateral stems
        for (int i = 0; i < this.lateralStems.Count; ++i)
        {
            LateralStem r = this.lateralStems[i];
            float r_t = Mathf.Clamp((this.totalTime - r.startTime) / r.duration, 0, 1);
            // Vector2 headPoint = r.growPointOffset.LinearInterpolate(r.targetHeadPosition, r_t);
            this.lateralStemGfxs[i].SetParameters(r.growPointOffset, r.targetHeadPosition, Mathf.Lerp(0, 0.5f, r_t), r.controlPoint0, r.controlPoint1, r_t, r.side);
        }
    }

    private void SpawnLateralStem(Side side, Vector2 position)
    {
        Vector2 targetPos = position + new Vector2(side == Side.RIGHT ? 15 : -15, -10) + new Vector2((side == Side.RIGHT ? 1 : -1) * GD.Randf(), GD.Randf()) * 5;
        this.lateralStems.Add(new LateralStem()
        {
            duration = 0.5f,
            startTime = this.totalTime,
            side = side,
            growPointOffset = position,
            targetHeadPosition = targetPos,
            controlPoint0 = position + (side == Side.RIGHT ? Vector2.Right : Vector2.Left) * (float)GD.RandRange(1, 15) + new Vector2(0, (float)GD.RandRange(-5, -20)),
            controlPoint1 = targetPos + new Vector2((side == Side.RIGHT ? -10 : 10) * GD.Randf(), (float)GD.RandRange(-10, 5)),
        });
        PackedScene lateralStemBase = ResourceLoader.Load<PackedScene>("res://juurtuva_pottu/LateralStemGfx.tscn");
        Node newNode = lateralStemBase.Instance();
        AddChild(newNode);
        this.lateralStemGfxs.Add(newNode as LateralStemGfx);
    }

    private void SpawnRootOrStolon(bool isRoot, Side side, Vector2 position)
    {
        if (isRoot)
        {
            Vector2 targetPos = position + new Vector2(side == Side.RIGHT ? 30 : -30, 50) + new Vector2((side == Side.RIGHT ? 1 : -1) * GD.Randf(), GD.Randf()) * 10;
            this.roots.Add(new Root()
            {
                duration = 1,
                startTime = this.totalTime,
                side = side,
                growPointOffset = position,
                targetHeadPosition = targetPos,
                controlPoint0 = position + (side == Side.RIGHT ? Vector2.Right : Vector2.Left) * (float)GD.RandRange(15, 50) + new Vector2(0, (float)GD.RandRange(-5, 20)),
                controlPoint1 = targetPos + new Vector2((side == Side.RIGHT ? -20 : 20) * GD.Randf(), (float)GD.RandRange(-10, 5)),
            });
            PackedScene rootBase = ResourceLoader.Load<PackedScene>("res://juurtuva_pottu/RootGfx.tscn");
            Node newNode = rootBase.Instance();
            AddChild(newNode);
            this.rootGfxs.Add(newNode as RootGfx);
        }
        else
        {
            Vector2 targetPos = position + new Vector2(side == Side.RIGHT ? 30 : -30, 30) + new Vector2((side == Side.RIGHT ? 1 : -1) * GD.Randf(), GD.Randf()) * 10;
            this.stolons.Add(new Stolon()
            {
                duration = 2,
                startTime = this.totalTime,
                side = side,
                growPointOffset = position,
                targetHeadPosition = targetPos,
                controlPoint0 = position + (side == Side.RIGHT ? Vector2.Right : Vector2.Left) * (float)GD.RandRange(20, 30),
                controlPoint1 = targetPos + new Vector2((side == Side.RIGHT ? -30 : 30) * GD.Randf(), (float)GD.RandRange(-10, 0)),
            });
            PackedScene stolonBase = ResourceLoader.Load<PackedScene>("res://juurtuva_pottu/StolonGfx.tscn");
            Node newNode = stolonBase.Instance();
            AddChild(newNode);
            this.stolonGfxs.Add(newNode as StolonGfx);
        }

    }

    private Vector2 GetRootPosition(int rootIndex)
    {
        float t = rootIndex / (float)GD.RandRange(9f, 11f);
        return this.stem.growPointOffset.LinearInterpolate(this.stem.groundBreakingPoint, t);
    }

    private Vector2 GetLateralStemPosition(int stemIndex)
    {
        float t = stemIndex / (float)GD.RandRange(10f, 13f);
        return this.stem.groundBreakingPoint.LinearInterpolate(this.stem.targetHeadPosition, t);
    }

    public Vector2[] GetRipePositions()
    {
        List<Vector2> result = new List<Vector2>();
        foreach (var stolon in this.stolons)
        {
            if (stolon.ripe)
            {
                result.Add(this.Position + stolon.targetHeadPosition);
            }
        }

        return result.ToArray();
    }
}

public struct Seed
{
    public float startTime;
    public float duration;
    public float growStartDelay;

    public float scale; // potato could be size 1 in game and grow to 2 while in soil 
}

public struct Stem
{
    public Vector2 growPointOffset;
    //public Vector2 headPoint;
    public Vector2 targetHeadPosition;
    public Vector2 groundBreakingPoint;
    public Vector2 controlPoint0;
    public Vector2 controlPoint1;
}

public struct LateralStem
{
    public Side side;
    public float startTime;
    public float duration;
    public Vector2 growPointOffset;
    public Vector2 targetHeadPosition;

    public Vector2 controlPoint0;
    public Vector2 controlPoint1;

}

public struct Root
{
    public Side side;
    public float startTime;
    public float duration;
    public Vector2 growPointOffset;
    public Vector2 targetHeadPosition;

    public Vector2 controlPoint0;
    public Vector2 controlPoint1;
}

public struct Stolon
{
    public Side side;

    public float startTime;
    public float duration;
    public Vector2 growPointOffset;
    public Vector2 targetHeadPosition;

    public Vector2 controlPoint0;
    public Vector2 controlPoint1;
    public bool ripe;

}

public enum Side
{
    LEFT,

    RIGHT,
}