include(joinpath(@__DIR__, "pt", "pt_pt.jl")) 

## Implement Spelled Out for Portugal Portuguese

#retuns a vector of ints, each of that 
function split_numbers_10³( num::Integer )
    digits( num, base = 10^3)  
end

function split_numbers_10⁶( num::Integer )
    digits( num, base = 10^6)  
end

#function 
function pt_pt_spell_1e3( number, short_one = false )
    if number <= 99 #0 - 99
        if number < 20 #1 - 20
            iszero(number) && return ""
            if isone(number) && short_one
                return "um"
            else
                return pt_PT_1_a_19[ number ]
            end
        else #20-99
            unit, dec = digits( number )
            if isone( unit ) && short_one
                unit_text = " e um"
            elseif iszero( unit )
                unit_text = ""
            else
                unit_text =  " e " * pt_PT_1_a_19[ unit ]
            end
            return pt_PT_dezenas[ dec ] * unit_text
        end
    elseif number ∈ centenas_dicionario
        unit, cent = digits( number, base = 100 )
        unit_text = pt_pt_spell_1e3( unit, short_one )
        return pt_PT_centenas[ cent ]
    elseif 100  <= number <= 999
        number == 100 && return "cem" 
        unit, cent = digits( number, base = 100 )
        unit_text = pt_pt_spell_1e3( unit, short_one )
        return pt_PT_centenas[ cent ] * " e "  * unit_text
    end
end

function pt_pt_spell_1e6( number, short_one = false )
    number = Int( number )
    number == 0 && return ""
    number == 1000 && return "mil"
    number <= 999 && return pt_pt_spell_1e3( number, short_one )
    low,high = digits( number, base = 1000 )
    low_txt = pt_pt_spell_1e3( low, short_one )
    if high == 1
        high_text = "mil e "
    else
        high_text = pt_pt_spell_1e3( high, false ) * " mil"
    end
    return high_text * low_txt
end

#spells only decimals, including 0
function pt_pt_spell_decimal( number, partitive = true )
    whole, decimal = split( string( number ), "." )
    decnum, wholenum = abs.( modf( number ) )
    decimal_length = length( decimal )
    decint = decnum*10^decimal_length
    if partitive
        if decimal_length > 6
            throw(error("""partitive pronunciation of Portugal Portuguese decimals is only supported to up to six decimals, the decimal part is $decimal .
            If you want english-like decimals (zero ponto dois), try using partitive = false.
            If the decimal part seems to differ from the perceived input number, try using big numbers: `big"123.23"`.
            """))
        end

        dectext = pt_pt_spell_1e6( Dec128( decint ), false )
        res = strip( dectext ) * " " * pt_PT_decimais[ decimal_length ]
        if decint != 1
            res = res * "s"
        end
        return res
    else
        res =  digits( decint ) .|> z-> pt_pt_spell_1e3( z, true ) .|> strip |> reverse |> z-> join( z," " )
        res = "ponto " * res
    end
end

function pt_pt_spell_large_map( number, i )
    if isone( i )
        return pt_pt_spell_1e6( number, true )
    elseif isone( number )
        return "um " * pt_PT_multiplos_1e6_singular[ i - 1 ]
    else
        return pt_pt_spell_1e6( number, false )
    end
end

function pt_pt_spell_large( _number )
    number = abs( _number ) 
    list = digits( number, base = 1_000_000 )
    res = pt_pt_spell_large_map.( list, 1:length( list ) ) .|> strip |> reverse |> z-> join( z," " ) 
    ( _number < 0 ) && ( res = "menos " * res )
    return res
end

function spelled_out_pt_pt( number; dict = :standard )
    if iszero( number )
        return "zero"
    end
    if isinteger( number )
        if dict in ( :standard, :large, :modern )
            res = pt_pt_spell_large( number )
        elseif dict in (:short,)
            res = pt_pt_spell_short( number )
        else
            throw( error( "unrecognized dict value: $dict" ) )
        end
        return res
    else #with decimals
        partitive = true
        _dec, _int = modf( number )
        _int = Dec128( _int )
        if ( _int == 0 ) & !partitive
            intres = "zero"
            
        elseif ( _int == 0 ) & partitive
            intres = ""
        elseif dict in ( :standard, :large, :modern )
            intres = pt_pt_spell_large( _int ) * " con "
        elseif dict in ( :short, )
            intres = pt_PT_spell_short( _int ) * " con "
        else
            throw( error( "unrecognized dict value: $dict" ) )
        end
            
        decres = pt_pt_spell_decimal( abs( _dec ) )
        return intres * decres
    end
end



