#                                           Ethos Integral Vario

for Ethos Tandem Transmitters

BETA 0.9
Januar 2024
Ethos >= 1.5



### This is a source script to allow to create an integral vario sensor.

The script allows you to create a "custom" telemetry sensor that outputs an averaged vario value.
A so called "integral vario"

This makes it possible to generate a variometer that provides information averaged over a longer period of time
(e.g. 3..4 thermal circles) to determine whether a "long-term" climb can actually be achieved under very weak conditions.

Finally, the respective altitude difference is determined via a time constant and the average climb is calculated from this 

Ethos 1.5 introduces a special function "playVario", which makes it possible to convert any sensors of the unit "m/s" as a variotone.
The script can therefore only be used from 1.5 onwards.





Das script erlaubt es einen „Custom“ Telemetriesensor anzulegen, der einen gemittelten Variowert ausgibt.

Somit wird es möglich, einen Varioton zu generieren, der einem über einem längeren Zeitraum
(z.B. 3..4 Thermik-Kreise) Auskunft darüber gibt, ob man tatsächlich unter sehr schwachen Bedingungen ein „langfristiges“ Steigen erzielt.

Letztlich wird über eine Zeitkonstante die jeweilige Höhendifferenz ermittelt, und daraus das durchschnittliche Steigen kalkuliert 

Mit Ethos 1.5 wird eine Spezialfunktion „playVario“ eingeführt, die es ermöglicht beliebige Sensoren der Einheit „m/s“ als Varioton umzusetzen.
Dies ist eine Grundvoraussetzung und daher ist das script erst ab 1.5 sinnvoll einsetzbar.




 
