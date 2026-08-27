module zahl.gzahl;

import zahl.nzahl;

struct Gzahl
{
    Nzahl grösse;
    bool positiv;

    //MARK: THIS()
    pure nothrow
    this(const Nzahl nz)
    {
        this.grösse = Nzahl(nz);
        this.positiv = false;
    }

    pure nothrow
    this(const Nzahl nz, bool positiv)
    {
        this.grösse = Nzahl(nz);
        this.positiv = positiv;
    }

    pure nothrow
    this(const ubyte[] werte, bool positiv)
    {
        this.grösse = Nzahl(werte);
        this.positiv = positiv;
    }

    pure nothrow
    this(const ubyte* werte, const ubyte länge, bool positiv)
    {
        this.grösse = Nzahl(werte, länge);
        this.positiv = positiv;
    }

    //MARK: opCmp
    int opCmp(ref const Gzahl other) const
    {
        if (this.positiv != other.positiv)
            return this.positiv ? 1 : -1;

        int nzahlResult = this.grösse.opCmp(other.grösse);

        if (!this.positiv)
            return -nzahlResult;

        return nzahlResult;
    }

    bool opEquals(const Gzahl other) const
    {
        return this.opCmp(other) == 0;
    }
}
