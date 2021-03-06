'Documentation
'Author: Omar Navarro
'Purpose:  To create functions of the following sort:
' File Handling
'String Handling
'Database Access
'Logging Utilities
'Error Handling Utilities 








Public Function old_framework()
	'Initialize initDic as the variables contained in the Init file.
	Set initDic = setInitDic(INIT_FILE_PATH)    '20
	Set globalParamsDic = getGlobalParams(initDic("params"))
	Set testSuiteDic = getTestSuite(initDic("params"))
	Set loginRecordSet = Util_GetRecordSet("login", "navarro.omar", initDic("testData"))
	loginRecordSet.MoveFirst
	logMessage "Login RecordSet has " & loginRecordSet.Fields.Count
	For i = 0 To loginRecordSet.Fields.Count
		logMessage "Field " & i & ": " & loginRecordSet.Fields.Item(i).Name
	Next
	
End Function



'########TO DO######## script scheduler that runs through the testSuiteDic.  There must be an excel file with the data.  
Sub initializeLog(logFilePath)
	Set logFileFSO = CreateObject("Scripting.FileSystemObject")
	Set logFile = logFileFSO.OpenTextFile(logFilePath, ForWriting, True)	
	logMessage 	LOG_SEPARATOR & vbCrLf & "Test log started at " & NOW(), 1
End Sub
     '31
Sub logMessage(msg, level)
	If level <= logLevel Then
		Dim s
		For i = 1 To level - 1
			s = s & vbTab
		Next		
		logFile.Write s & msg & vbCrLf
	End If	
End Sub
      '41
'Sub logMessage(msg)
'	logMessage msg, 3
'End Sub

Sub releaseLog
	logFile.Close
End Sub

Function setInitDic(initFilePath)
	Set initFileFSO = CreateObject("Scripting.FileSystemObject")   '51
	Set initFileDictionary = CreateObject("Scripting.Dictionary")
	If initFileFSO.FileExists(initFilePath) Then
		Set initFileStr = initFileFSO.OpenTextFile(initFilePath, ForReading, False)
		While Not initFileStr.AtEndOfStream
			line = initFileStr.ReadLine()
			If Not isComment(line) Then
				argStr = Split(line, ARGUMENT_SPLITTER)
				If UBound(argStr) = 1 Then
					initFileDictionary.Add Trim(argStr(0)), Trim(argStr(1))
				End If			'61
			End If
		Wend
		
		If initFileDictionary.Exists("logLevel")  Then
			logLevel = Cint(initFileDictionary("logLevel"))			
		Else
			logLevel = DEFAULT_LOG_LEVEL 
		End If
		
		If initFileDictionary.Exists("logFilePath") Then    '71
			initializeLog(initFileDictionary("logFilePath"))			
		Else
			initializeLog(DEFAULT_LOG_FILE_PATH)
		End If

		logMessage LOG_SEPARATOR & vbCrLf & "Initializer Dictionary contains the following keys:", 3
		
		For Each key in initFileDictionary			
			logMessage "Key: " & key & " Value: " & initFileDictionary(key), 3
		Next

		Set setInitDic = initFileDictionary    '83
	Else
		Set setInitDic = null
	End If
	
End Function

Function getParamsXMLDoc(xmlDocFilePath)  '90
	Set dataXMLDoc = CreateObject("Microsoft.XMLDOM")
	Set globalParamsDictionary = CreateObject("Scripting.Dictionary")
	dataXMLDoc.async = False
	dataXMLDoc.Load(paramsPath)
	Set getParamsXMLDoc = dataXMLDoc

End Function

Function isComment(lineStr)
	retVal = False
	If InStr(lineStr, COMMENT_STARTER) = 1  Then
		retVal = True      '102
	End If
	isComment = retVal
End Function

Function getGlobalParams(paramsPath)
	Set dataXMLDoc = CreateObject("Microsoft.XMLDOM")
	Set globalParamsDictionary = CreateObject("Scripting.Dictionary")
	dataXMLDoc.async = False
	dataXMLDoc.Load(paramsPath)
	Set ROOT = dataXMLDoc.DocumentElement    
	Set globalParamsNodeColl = ROOT.getElementsByTagName("GLOBAL")   '110
	logMessage LOG_SEPARATOR & vbCrLf & "Global params dictionary contains the following keys:", 3
	For each globalNode in globalParamsNodeColl
		If globalNode.hasChildNodes Then
			Set globalChildNodesColl = globalNode.childNodes
			For each globalChildNode in globalChildNodesColl
				globalParamsDictionary.Add globalChildNode.nodeName, globalChildNode.Text
				logMessage "Key: " & globalChildNode.nodeName & " Value: " & globalChildNode.Text, 3	
			Next
		End If
		'113
	Next
	If globalParamsDictionary.Count > 0 Then
		logMessage "global Params dictionary contains " & globalParamsDictionary.Count & " entries.", 3
		Set getGlobalParams = globalParamsDictionary
	Else
		logMessage "global Params dictionary contains no entries.", 3
		Set getGlobalParams = null  '120
	End If
	
End Function

Function getTestSuite(paramsPath)
	Set dataXMLDoc = CreateObject("Microsoft.XMLDOM")
	Set testSuiteDictionary = CreateObject("Scripting.Dictionary")
	dataXMLDoc.async = False
	dataXMLDoc.Load(paramsPath)
	Set ROOT = dataXMLDoc.DocumentElement    '130
	Set testSuiteNodesColl = ROOT.getElementsByTagName("TEST_SUITE")
	'logMessage LOG_SEPARATOR & vbCrLf & "Test Suite dictionary contains the following keys:", 3
	testSuiteDictionary.Add "test_suite", testSuiteNodesColl.Item(0)
	For each testSuiteNode in testSuiteNodesColl 
		If testSuiteNode.hasChildNodes Then
			logMessage LOG_SEPARATOR & vbCrLf & "Test Suite dictionary contains " & testSuiteNode.childNodes.length  & " keys.", 3
'			testSuiteDictionary.Add count testsColl = testSuiteNode.childNodes
'			For each testNode in testsColl
'				testSuiteDictionary.Add testNode.nodeName, testNode.Text
'				logMessage "Key: " & testNode.nodeName & " Value: " & testNode.Text, 3	
'			Next
		End If      '142
	Next
	If testSuiteDictionary.Count > 0 Then
		logMessage "Test Suite dictionary contains " & testSuiteDictionary.Count & " entries.", 3
		Set getTestSuite = testSuiteDictionary
	Else
		logMessage "Test Suite dictionary contains no entries.", 3
		Set getTestSuite = null
	End If
	
End Function   '152

Function Util_GetRecordSet(tableName, rowReference, dataSource)
	Set objConnection = CreateObject("ADODB.Connection")
	Set objRecordSet = CreateObject("ADODB.Recordset")

	objConnection.Open "Provider=Microsoft.Jet.OLEDB.4.0;" & _
	    "Data Source=" & dataSource & ";" & _	
	    "Extended Properties=""Excel 8.0;HDR=Yes;"";" 

	objRecordset.Open "Select * FROM [" & tableName & "$] where " & UCASE(tableName) & "_REFERENCE", _
    	    objConnection, adOpenStatic, adLockOptimistic, adCmdText
	
	Set Util_GetRecordSet = objRecordSet
	
End Function


