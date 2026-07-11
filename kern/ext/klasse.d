module ext.klasse;

public nothrow @safe
bool instanceof(T, O)(O obj)
{
	static if (is(T == class) || is(T == interface))
	{
		return cast(T) obj !is null;
	}
	else
	{
		return false;
	}
}
