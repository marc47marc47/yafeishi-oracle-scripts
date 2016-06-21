'******************************************************************************
'* File:     pdm2excel.txt
'* Title:    pdm export to excel
'* Purpose:  To export the tables and columns to Excel
'* Model:    Physical Data Model
'* Objects:  Table, Column, View
'* Author:   ziyan
'* Modify:   danghb
'* Modified: 2014-04-29
'* Created:  2012-05-03
'* Version:  1.1
'******************************************************************************
'********************************************
'更新内容：
'	每张表一个sheet
'   显示内容改成：表名，字段名，字段类型，字段说明
'	在第一个sheet显示表的汇总
'********************************************
Option Explicit
   Dim rowsNum
   rowsNum = 0
'-----------------------------------------------------------------------------
' Main function
'-----------------------------------------------------------------------------
' Get the current active model
Dim Model
Set Model = ActiveModel
If (Model Is Nothing) Or (Not Model.IsKindOf(PdPDM.cls_Model)) Then
  MsgBox "The current model is not an PDM model."
Else
 ' Get the tables collection
 '创建EXCEL APP
 dim beginrow
 DIM EXCEL, SHEET
 set EXCEL = CREATEOBJECT("Excel.Application")
 EXCEL.workbooks.add '添加工作表

 'ShowTablesAll  Model, SHEET
 ShowProperties Model, SHEET
 ShowTablesAll  Model, SHEET
 EXCEL.visible = true 
 End If
'-----------------------------------------------------------------------------
' Show properties of tables
'-----------------------------------------------------------------------------

Sub ShowTablesAll(mdl,sheet)
	Dim tabnum
	tabnum=1
	EXCEL.Sheets.Add  '插入新的Sheet
    EXCEL.ActiveSheet.Name = "汇总"  '重新命名新的Sheetc
    set sheet = EXCEL.workbooks(1).sheets("汇总") 
	sheet.cells(tabnum,2) = "表名"
	sheet.cells(tabnum,3) = "表说明"
	sheet.Columns(2).ColumnWidth = 40 
	sheet.Columns(3).ColumnWidth = 40
	sheet.Columns(3).WrapText =true
	tabnum=tabnum+1
    Dim tab  
	Dim Anchor
	For Each tab In mdl.tables
		sheet.cells(tabnum,2) = tab.code
		'link(sheet.range(sheet.cells(tabnum,2),tab))
		'ActiveSheet.Hyperlinks.Add anchor:=sheet.range(sheet.cells(tabnum,2), Address:="", SubAddress:= _tab.code+"!A1"
		sheet.cells(tabnum,3) = tab.comment
	    tabnum=tabnum+1
    Next
	output "executed ShowTablesAll:  "+ Cstr(tabnum)
End Sub	



Sub ShowProperties(mdl, sheet)
   ' Show tables of the current model/package
   rowsNum=0
   beginrow = rowsNum+1
   ' For each table
   output "begin"
   Dim tab
   For Each tab In mdl.tables
      EXCEL.Sheets.Add   '插入新的Sheet
      EXCEL.ActiveSheet.Name = tab.code   '重新命名新的Sheet
      set sheet = EXCEL.workbooks(1).sheets(tab.code) 
      ShowTable tab,sheet
   Next 
   output "end " + "all: " + Cstr(mdl.tables.count) + " tables"
End Sub
'-----------------------------------------------------------------------------
' Show table properties
'-----------------------------------------------------------------------------
Sub ShowTable(tab, sheet)

   If IsObject(tab) Then
     Dim rangFlag
	 rowsNum=0
     rowsNum = rowsNum + 1  
	 
	 
      '设置列宽和自动换行
      sheet.Columns(1).ColumnWidth = 40 
      sheet.Columns(2).ColumnWidth = 20 
	  sheet.Columns(3).ColumnWidth = 20 
      sheet.Columns(4).ColumnWidth = 40  
      sheet.Columns(1).WrapText =true 
      sheet.Columns(4).WrapText =true
    
      ' Show properties
      Output "================================" 
      sheet.cells(rowsNum, 1) = "表名"
      sheet.cells(rowsNum, 2) = tab.code
      sheet.Range(sheet.cells(rowsNum, 2),sheet.cells(rowsNum, 4)).Merge
      rowsNum = rowsNum + 1 
      sheet.cells(rowsNum, 1) = "字段中文名"
      sheet.cells(rowsNum, 2) = "字段名"
      sheet.cells(rowsNum, 3) = "字段类型"
	  sheet.cells(rowsNum, 4) = "说明"
	  sheet.Range("B1").HorizontalAlignment = 3 
	  sheet.Range("B1").Font.Bold = True   
      '设置边框
      sheet.Range(sheet.cells(rowsNum-1, 1),sheet.cells(rowsNum, 4)).Borders.LineStyle = "1" 
Dim col ' running column
Dim colsNum
colsNum = 0
      for each col in tab.columns
        rowsNum = rowsNum + 1
        colsNum = colsNum + 1 
      sheet.cells(rowsNum, 1) = col.name
      sheet.cells(rowsNum, 2) = col.code
      sheet.cells(rowsNum, 3) = col.datatype 
      sheet.cells(rowsNum, 4) = col.comment
      next
      sheet.Range(sheet.cells(rowsNum-colsNum+1,1),sheet.cells(rowsNum,2)).Borders.LineStyle = "2"  
      rowsNum = rowsNum + 1
      
      Output "FullDescription: "       + tab.Name
   End If
End Sub