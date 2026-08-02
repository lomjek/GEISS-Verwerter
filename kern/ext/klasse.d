module ext.klasse;

/// Checks wether obj O is an instance of the
/// exact class proivded as type.
public nothrow @safe
bool is_class(T, O)(O obj)
{
	static if (is(T == class) && (is(O == class) || is(O == interface)))
		return obj !is null && obj.classinfo is T.classinfo;
	else
		return false;
}

/// Checks wether obj O is an instance of the
/// class OR ANY OF IT'S SUBCLASSES.
/// Should work like Java's instanceof 
public nothrow @safe
bool instanceof(T, O)(O obj)
{
	static if (is(T == class) || is(T == interface))
	{
		if (obj is null)
			return false;

		for (auto info = obj.classinfo; info !is null; info = info.base)
		{
			static if (is(T == class))
			{
				if (info is T.classinfo)
					return true;
			}
			else static if (is(T == interface))
			{
				foreach (iface; info.interfaces)
				{
					if (iface.classace is T.classinfo)
						return true;
				}
			}
		}
		return false;
	}
	else
		return false;
}
