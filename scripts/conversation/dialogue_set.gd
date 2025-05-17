class_name DialogueSet

var initial_prompt: String
var neutral_quotes: RandomNonRepeatingArray
var positive_quotes: RandomNonRepeatingArray
var negative_quotes: RandomNonRepeatingArray
var success_quote: String
var failure_quote: String

var used_neutral_qoutes


func _init(file_path: String):
    parse(file_path)

func parse(file_path: String):
    var file := FileAccess.open(file_path, FileAccess.READ)
    initial_prompt = file.get_line()
    neutral_quotes = parse_section(file, "NORMAL")
    positive_quotes = parse_section(file, "PLEASED")
    negative_quotes = parse_section(file, "UPSET")
    success_quote = get_first_line_under_header(file, "SUCCESS")
    failure_quote = get_first_line_under_header(file, "FAILURE")


func parse_section(
    file: FileAccess, header: String
) -> RandomNonRepeatingArray:
    return RandomNonRepeatingArray.new(
        _parse_section(file, header)
    )

func _parse_section(
    file: FileAccess, header: String
) -> Array[String]:
    var line := get_first_line_under_header(file, header)
    if file.eof_reached(): return []
    var result: Array[String] = []
    while !line.is_empty():
        result.append(line)
        line = file.get_line()
    return result


func get_first_line_under_header(
    file: FileAccess, header: String
) -> String:
    while file.get_line() != header:
        if file.eof_reached(): return ""
    return file.get_line()
