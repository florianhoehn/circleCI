ant validate | tee buildResults

if grep -q "Request Status: Failed" buildResults
then
	echo "Oooops, you broke the build..."
	exit 1
else
	echo "All good, go on coding."
	fi
exit 0