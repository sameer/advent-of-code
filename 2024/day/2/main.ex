reports =
  Enum.map(
    Enum.filter(String.split(File.open!("input"), "\n"), fn r -> String.length(r) > 0 end),
    fn report -> String.split(report) end
  )
