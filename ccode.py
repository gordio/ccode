# -*- coding: utf-8 -*-
import sublime, sublime_plugin


class Ccode(sublime_plugin.EventListener):
	# TODO: Init options

	def on_modified(self, view):
		file_name = view.file_name()

		# chech suported files
		if not file_name.endswith(('.c', '.h', '.m', '.cpp', '.hpp', '.cc', '.mm')):
			return

		caret = view.sel()[0].begin()
		cur_char = view.substr(caret-1)
		prev_char = view.substr(caret-2)

		# check if need open completions
		# TODO: configurable autocompletions
 		if cur_char == ".":
 			if self.get_completions(view):
 				view.run_command('auto_complete')
 		elif cur_char == ">" and prev_char == "-":
 			if self.get_completions(view):
 				view.run_command('auto_complete')
 		elif file_name.endswith(('.cpp', '.hpp', '.cc', '.mm')) and cur_char == ":" and prev_char == ":":
 			if self.get_completions(view):
 				view.run_command('auto_complete')


 	def buf_to_tmp_file(self, view):
 		from tempfile import NamedTemporaryFile


 		buff = view.substr(sublime.Region(0, view.size()))

 		# FIXME: Use file codepage?
 		tmp_file = NamedTemporaryFile(delete=False)
 		buff_utf8 = buff.encode('UTF-8')
 		tmp_file.write(buff_utf8)

 		return tmp_file.name


 	def on_query_completions(self, view, prefix, locations):
 		caret = view.sel()[0].begin()
		cur_char = view.substr(caret-1)
		prev_char = view.substr(caret-2)

		# check if need (and exist) completions
		if cur_char == ".":
 			return self.get_completions(view)
 		elif cur_char == ">" and prev_char == "-":
 			return self.get_completions(view)
 		elif cur_char == ":" and prev_char == ":":
 			return self.get_completions(view)

 		return []


 	def get_completions(self, view):
 		from subprocess import Popen, PIPE
		from os import unlink
		import json


		# TODO: Use cache
		completions = []

		# make args
 		caret = view.sel()[0].begin()
 		row, col = view.rowcol(caret)
		file_name = view.file_name()
		file = self.buf_to_tmp_file(view)

		# execute program
 		proc = Popen(['ccode', 'ac', str(file_name), str(row+1), str(col+1), file], stdout=PIPE)
 		ret = proc.wait()

 		unlink(file)

 		# check error code
 		if ret != 0:
 			# TODO: Parse stderr
 			status_message("CCode: Error %s" % ret)
 			return []

 		# get stdout and fix json
 		data = ""
 		for line in proc.stdout:
 			data += line.replace("'", "\"")

 		# parse json and add to completions
 		for i in json.loads(data)[1]:
 			completions.append((i["abbr"], i["word"]))

 		return completions