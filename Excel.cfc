<cfcomponent
    displayname="Excel"
    output="false"
    hint="Leitura e escrita de arquivos Microsoft Excel">


    <cffunction name="Init" access="public" returntype="Excel" output="false"
        hint="Retorna uma instancia Excel">

        <!--- Return This reference. --->
        <cfreturn THIS />
    </cffunction>


    <cffunction name="GetNewSheetStruct" access="public" returntype="struct" output="false"
        hint="Retorna uma estrutura padrão desse componente para geração de arquivos Excel">

        <!--- Define the local scope. --->
        <cfset var LOCAL = StructNew() />

        <cfscript>
            // Query utilizada para manter os dados
            LOCAL.Query = "";
            // Lista de campos de banco de dados na ordem desejada
            LOCAL.ColumnList = "";
            // Lista dos nomes de coluna para o cabeçalho do arquivo Excel
            LOCAL.ColumnNames = "";
            // Nome da planilha
            LOCAL.SheetName = "";
            // Retorna a estrutura LOCAL contendo as propriedades da planilha
            return( LOCAL );
        </cfscript>
    </cffunction>


    <cffunction name="ReadExcel" access="public" returntype="any" output="false"
        hint="Lê um arquivo Excel em um array de estruturas contendo informações do arquivo ou de uma planilha específica">

        <!--- Define arguments. --->
        <cfargument
            name="FilePath"
            type="string"
            required="true"
            hint="Caminho do arquivo Excel"
            />

        <cfargument
            name="HasHeaderRow"
            type="boolean"
            required="false"
            default="false"
            hint="Indica que a primeira linha é um cabeçalho de colunas. Se for, a coluna será excluída da query resultante."
            />

        <cfargument
            name="SheetIndex"
            type="numeric"
            required="false"
            default="-1"
            hint="Se for definido, apenas um objeto planilha será retornado (e não um array de objetos)."
            />

        <cfscript>
            // Define a estrutura LOCAL
            var LOCAL = StructNew();
            // Cria um objeto Excel. É responsável pela leitura de um arquivo Excel.
            LOCAL.ExcelFileSystem = CreateObject(
                "java",
                "org.apache.poi.poifs.filesystem.POIFSFileSystem"
                ).Init(
                    // Create the file input stream.
                    CreateObject(
                        "java",
                        "java.io.FileInputStream"
                        ).Init(
                            ARGUMENTS.FilePath
                            )
                    );
            // Obter a pasta de trabalho do arquivo Excel
            LOCAL.WorkBook = CreateObject(
                "java",
                "org.apache.poi.hssf.usermodel.HSSFWorkbook"
                ).Init(
                    LOCAL.ExcelFileSystem
                    );
            // Checar se o retorno é um array de objetos ou apenas uma planilha
            if (ARGUMENTS.SheetIndex GTE 0){
                // Retorna apenas uma planilha
                return(
                    ReadExcelSheet(
                        LOCAL.WorkBook,
                        ARGUMENTS.SheetIndex,
                        ARGUMENTS.HasHeaderRow
                        )
                    );
            } else {
                // Retorna uma array de objetos Planilha
                LOCAL.Sheets = ArrayNew( 1 );
                // Loop sobre as planilhas da pasta de trabalho
                for (
                    LOCAL.SheetIndex = 0 ;
                    LOCAL.SheetIndex LT LOCAL.WorkBook.GetNumberOfSheets() ;
                    LOCAL.SheetIndex = (LOCAL.SheetIndex + 1)
                    ){
                    // Adiciona informações de planilha
                    ArrayAppend(
                        LOCAL.Sheets,
                        ReadExcelSheet(
                            LOCAL.WorkBook,
                            LOCAL.SheetIndex,
                            ARGUMENTS.HasHeaderRow
                            )
                        );
                }
                // Retorna o array de planilhas
                return( LOCAL.Sheets );
            }
        </cfscript>
    </cffunction>


    <cffunction name="WriteExcelSheet" access="public" returntype="void" output="false"
        hint="Writes the given 'Sheet' structure to the given workbook.">

        <!--- Define arguments. --->
        <cfargument
            name="WorkBook"
            type="any"
            required="true"
            hint="This is the Excel workbook that will create the sheets."
            />

        <cfargument
            name="Query"
            type="any"
            required="true"
            hint="This is the query from which we will get the data."
            />

        <cfargument
            name="ColumnList"
            type="string"
            required="false"
            default="#ARGUMENTS.Query.ColumnList#"
            hint="This is list of columns provided in custom-ordered."
            />

        <cfargument
            name="ColumnNames"
            type="string"
            required="false"
            default=""
            hint="This the the list of optional header-row column names. If this is not provided, no header row is used."
            />

        <cfargument
            name="SheetName"
            type="string"
            required="false"
            default="Sheet #(ARGUMENTS.WorkBook.GetNumberOfSheets() + 1)#"
            hint="This is the optional name that appears in this sheet's tab."
            />

        <cfargument
            name="Delimiters"
            type="string"
            required="false"
            default=","
            hint="The list of delimiters used for the column list and column name arguments."
            />

        <cfscript>
            // Set up local scope.
            var LOCAL = StructNew();
            // Set up data type map so that we can map each column name to
            // the type of data contained.
            LOCAL.DataMap = StructNew();
            // Get the meta data of the query to help us create the data mappings.
            LOCAL.MetaData = GetMetaData( ARGUMENTS.Query );
            // Loop over meta data values to set up the data mapping.
            for (
                LOCAL.MetaIndex = 1 ;
                LOCAL.MetaIndex LTE ArrayLen( LOCAL.MetaData ) ;
                LOCAL.MetaIndex = (LOCAL.MetaIndex + 1)
                ){
                // Map the column name to the data type.
                LOCAL.DataMap[ LOCAL.MetaData[ LOCAL.MetaIndex ].Name ] = LOCAL.MetaData[ LOCAL.MetaIndex ].TypeName;
            }
            // Create the sheet in the workbook.
            LOCAL.Sheet = ARGUMENTS.WorkBook.CreateSheet(
                JavaCast(
                    "string",
                    ARGUMENTS.SheetName
                    )
                );
            // Set a default row offset so that we can keep add the header
            // column without worrying about it later.
            LOCAL.RowOffset = -1;
            // Check to see if we have any column names. If we do, then we
            // are going to create a header row with these names in order
            // based on the passed in delimiter.
            if (Len( ARGUMENTS.ColumnNames )){
                // Convert the column names to an array for easier
                // indexing and faster access.
                LOCAL.ColumnNames = ListToArray(
                    ARGUMENTS.ColumnNames,
                    ARGUMENTS.Delimiters
                    );
                // Create a header row.
                LOCAL.Row = LOCAL.Sheet.CreateRow(
                    JavaCast( "int", 0 )
                    );
                // Loop over the column names.
                for (
                    LOCAL.ColumnIndex = 1 ;
                    LOCAL.ColumnIndex LTE ArrayLen( LOCAL.ColumnNames ) ;
                    LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)
                    ){
                    // Create a cell for this column header.
                    LOCAL.Cell = LOCAL.Row.CreateCell(
                        JavaCast( "int", (LOCAL.ColumnIndex - 1) )
                        );
                    // Set the cell value.
                    LOCAL.Cell.SetCellValue(
                        JavaCast(
                            "string",
                            LOCAL.ColumnNames[ LOCAL.ColumnIndex ]
                            )
                        );
                }
                // Set the row offset to zero since this will take care of
                // the zero-based index for the rest of the query records.
                LOCAL.RowOffset = 0;
            }
            // Convert the list of columns to the an array for easier
            // indexing and faster access.
            LOCAL.Columns = ListToArray(
                ARGUMENTS.ColumnList,
                ARGUMENTS.Delimiters
                );
            // Loop over the query records to add each one to the
            // current sheet.
            for (
                LOCAL.RowIndex = 1 ;
                LOCAL.RowIndex LTE ARGUMENTS.Query.RecordCount ;
                LOCAL.RowIndex = (LOCAL.RowIndex + 1)
                ){
                // Create a row for this query record.
                LOCAL.Row = LOCAL.Sheet.CreateRow(
                    JavaCast(
                        "int",
                        (LOCAL.RowIndex + LOCAL.RowOffset)
                        )
                    );
                // Loop over the columns to create the individual data cells
                // and set the values.
                for (
                    LOCAL.ColumnIndex = 1 ;
                    LOCAL.ColumnIndex LTE ArrayLen( LOCAL.Columns ) ;
                    LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)
                    ){
                    // Create a cell for this query cell.
                    LOCAL.Cell = LOCAL.Row.CreateCell(
                        JavaCast( "int", (LOCAL.ColumnIndex - 1) )
                        );
                    // Get the generic cell value (short hand).
                    LOCAL.CellValue = ARGUMENTS.Query[
                        LOCAL.Columns[ LOCAL.ColumnIndex ]
                        ][ LOCAL.RowIndex ];
                    // Check to see how we want to set the value. Meaning, what
                    // kind of data mapping do we want to apply? Get the data
                    // mapping value.
                    LOCAL.DataMapValue = LOCAL.DataMap[ LOCAL.Columns[ LOCAL.ColumnIndex ] ];
                    // Check to see what value type we are working with. I am
                    // not sure what the set of values are, so trying to keep
                    // it general.
                    if (REFindNoCase( "int", LOCAL.DataMapValue )){
                        LOCAL.DataMapCast = "int";
                    } else if (REFindNoCase( "long", LOCAL.DataMapValue )){
                        LOCAL.DataMapCast = "long";
                    } else if (REFindNoCase( "double", LOCAL.DataMapValue )){
                        LOCAL.DataMapCast = "double";
                    } else if (REFindNoCase( "float|decimal|real|date|time", LOCAL.DataMapValue )){
                        LOCAL.DataMapCast = "float";
                    } else if (REFindNoCase( "bit", LOCAL.DataMapValue )){
                        LOCAL.DataMapCast = "boolean";
                    } else if (REFindNoCase( "char|text|memo", LOCAL.DataMapValue )){
                        LOCAL.DataMapCast = "string";
                    } else if (IsNumeric( LOCAL.CellValue )){
                        LOCAL.DataMapCast = "float";
                    } else {
                        LOCAL.DataMapCast = "string";
                    }
                    // Cet the cell value using the data map casting that we
                    // just determined and the value that we previously grabbed
                    // (for short hand).
                    LOCAL.Cell.SetCellValue(
                        JavaCast(
                            LOCAL.DataMapCast,
                            LOCAL.CellValue
                            )
                        );
                }
            }
            // Return out.
            return;
        </cfscript>
    </cffunction>

    <cffunction name="WriteExcel" access="public" returntype="void" output="false"
        hint="Takes an array of 'Sheet' structure objects and writes each of them to a tab in the Excel file.">

        <!--- Define arguments. --->
        <cfargument
            name="FilePath"
            type="string"
            required="true"
            hint="This is the expanded path of the Excel file."
            />

        <cfargument
            name="Sheets"
            type="any"
            required="true"
            hint="This is an array of the data that is needed for each sheet of the excel OR it is a single Sheet object. Each 'Sheet' will be a structure containing the Query, ColumnList, ColumnNames, and SheetName."
            />

        <cfargument
            name="Delimiters"
            type="string"
            required="false"
            default=","
            hint="The list of delimiters used for the column list and column name arguments."
            />

        <cfscript>
            // Set up local scope.
            var LOCAL = StructNew();
            // Create Excel workbook.
            LOCAL.WorkBook = CreateObject(
                "java",
                "org.apache.poi.hssf.usermodel.HSSFWorkbook"
                ).Init();
            // Check to see if we are dealing with an array of sheets or if we were
            // passed in a single sheet.
            if (IsArray( ARGUMENTS.Sheets )){
                // This is an array of sheets. We are going to write each one of them
                // as a tab to the Excel file. Loop over the sheet array to create each
                // sheet for the already created workbook.
                for (
                    LOCAL.SheetIndex = 1 ;
                    LOCAL.SheetIndex LTE ArrayLen( ARGUMENTS.Sheets ) ;
                    LOCAL.SheetIndex = (LOCAL.SheetIndex + 1)
                    ){
                    // Create sheet for the given query information..
                    WriteExcelSheet(
                        WorkBook = LOCAL.WorkBook,
                        Query = ARGUMENTS.Sheets[ LOCAL.SheetIndex ].Query,
                        ColumnList = ARGUMENTS.Sheets[ LOCAL.SheetIndex ].ColumnList,
                        ColumnNames = ARGUMENTS.Sheets[ LOCAL.SheetIndex ].ColumnNames,
                        SheetName = ARGUMENTS.Sheets[ LOCAL.SheetIndex ].SheetName,
                        Delimiters = ARGUMENTS.Delimiters
                        );
                }
            } else {
                // We were passed in a single sheet object. Write this sheet as the
                // first and only sheet in the already created workbook.
                WriteExcelSheet(
                    WorkBook = LOCAL.WorkBook,
                    Query = ARGUMENTS.Sheets.Query,
                    ColumnList = ARGUMENTS.Sheets.ColumnList,
                    ColumnNames = ARGUMENTS.Sheets.ColumnNames,
                    SheetName = ARGUMENTS.Sheets.SheetName,
                    Delimiters = ARGUMENTS.Delimiters
                    );
            }
            // ASSERT: At this point, either we were passed a single Sheet object
            // or we were passed an array of sheets. Either way, we now have all
            // of sheets written to the WorkBook object.
            // Create a file based on the path that was passed in. We will stream
            // the work data to the file via a file output stream.
            LOCAL.FileOutputStream = CreateObject(
                "java",
                "java.io.FileOutputStream"
                ).Init(
                    JavaCast(
                        "string",
                        ARGUMENTS.FilePath
                        )
                    );
            // Write the workout data to the file stream.
            LOCAL.WorkBook.Write(
                LOCAL.FileOutputStream
                );
            // Close the file output stream. This will release any locks on
            // the file and finalize the process.
            LOCAL.FileOutputStream.Close();
            // Return out.
            return;
        </cfscript>
    </cffunction>

    <cffunction name="WriteSingleExcel" access="public" returntype="void" output="false"
        hint="Write the given query to an Excel file.">

        <!--- Define arguments. --->
        <cfargument
            name="FilePath"
            type="string"
            required="true"
            hint="Caminho para geração do arquivo Excel"
            />

        <cfargument
            name="Query"
            type="query"
            required="true"
            hint="Nome da Query utilizada para gerar o arquivo Excel"
            />

        <cfargument
            name="ColumnList"
            type="string"
            required="false"
            default="#ARGUMENTS.Query.ColumnList#"
            hint="Nome dos campos de banco na ordem desejada"
            />

        <cfargument
            name="ColumnNames"
            type="string"
            required="false"
            default=""
            hint="Cabeçalho de colunas (Opcional)"
            />

        <cfargument
            name="SheetName"
            type="string"
            required="false"
            default="Sheet 1"
            hint="Nome da planilha (Opcional)"
            />

        <cfargument
            name="Delimiters"
            type="string"
            required="false"
            default=","
            hint="Lista de delimitadores utilizada nos argumentos lista de colunas e nome de colunas (o padrão é vírgula)"
            />

        <cfscript>
            // Definir variável de estrutura LOCAL
            var LOCAL = StructNew();
            // Obter um novo objeto tipo Planilha
            LOCAL.Sheet = GetNewSheetStruct();
            // Definir as propriedades da planilha
            LOCAL.Sheet.Query = ARGUMENTS.Query;
            LOCAL.Sheet.ColumnList = ARGUMENTS.ColumnList;
            LOCAL.Sheet.ColumnNames = ARGUMENTS.ColumnNames;
            LOCAL.Sheet.SheetName = ARGUMENTS.SheetName;
            // Gravar a planilha como um arquivo Excel
            WriteExcel(
                FilePath = ARGUMENTS.FilePath,
                Sheets = LOCAL.Sheet,
                Delimiters = ARGUMENTS.Delimiters
                );
            // Return out.
            return;
        </cfscript>
    </cffunction>
</cfcomponent>