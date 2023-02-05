using Godot;
public static class CurveTools
{

    public static Vector2 CubicBezier(Vector2 p0, Vector2 c0, Vector2 c1, Vector2 p1, float t)
    {
        Vector2 q0 = p0.LinearInterpolate(c0, t);
        Vector2 q1 = c0.LinearInterpolate(c1, t);
        Vector2 q2 = c1.LinearInterpolate(p1, t);

        Vector2 r0 = q0.LinearInterpolate(q1, t);
        Vector2 r1 = q1.LinearInterpolate(q2, t);

        Vector2 s = r0.LinearInterpolate(r1, t);
        return s;
    }
}