file="t1.txt"
while IFS= read line
do
        # display $line or do something with $line
	echo "$line" >> t3.txt
done <"$file"
