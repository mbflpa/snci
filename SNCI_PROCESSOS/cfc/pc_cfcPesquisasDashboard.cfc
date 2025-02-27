<cfcomponent>
    <cffunction name="getPesquisas" access="remote" returntype="string" returnformat="json">
        <cfargument name="ano" type="string" required="true">
        
        <cfquery name="qPesquisas" datasource="#application.dsn_processos#">
            SELECT 
                pc_pesq_id,
                pc_usu_matricula,
                pc_processo_id,
                CONCAT(pc_orgaos.pc_org_sigla,' (',pc_orgaos.pc_org_mcu,')') as orgaoResposta,
                pc_pesq_comunicacao,
                pc_pesq_interlocucao,
                pc_pesq_reuniao_encerramento,
                pc_pesq_relatorio,
                pc_pesq_pos_trabalho,
                pc_pesq_importancia_processo,
                pc_pesq_pontualidade, 
                pc_pesq_observacao,
                FORMAT(pc_pesq_data_hora, 'dd/MM/yyyy') as pc_pesq_data_hora
            FROM pc_pesquisas
            INNER JOIN pc_orgaos ON pc_pesquisas.pc_org_mcu = pc_orgaos.pc_org_mcu
            WHERE RIGHT(pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            ORDER BY pc_processo_id
        </cfquery>
        
        <cfreturn serializeJSON(qPesquisas)>
    </cffunction>

    <cffunction name="getEstatisticas" access="remote" returntype="struct" output="false">
        <cfargument name="ano" type="string" required="true">
        
        <cfset var retorno = structNew()>
        <cfset var qryPesquisas = "">
        <cfset var qryEvolucao = "">
        
        <cfquery name="qryPesquisas" datasource="#application.dsn_processos#">
            SELECT 
                COUNT(*) as total_pesquisas,
                COALESCE(CAST(AVG(CAST(pc_pesq_comunicacao AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_comunicacao,
                COALESCE(CAST(AVG(CAST(pc_pesq_interlocucao AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_interlocucao,
                COALESCE(CAST(AVG(CAST(pc_pesq_reuniao_encerramento AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_reuniao,
                COALESCE(CAST(AVG(CAST(pc_pesq_relatorio AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_relatorio,
                COALESCE(CAST(AVG(CAST(pc_pesq_pos_trabalho AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_pos_trabalho,
                COALESCE(CAST(AVG(CAST(pc_pesq_importancia_processo AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_importancia,
                COALESCE(CAST(AVG(CAST(pc_pesq_pontualidade AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_pontualidade
            FROM pc_pesquisas 
            WHERE RIGHT(pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
        </cfquery>
    
        <cfquery name="qryEvolucao" datasource="#application.dsn_processos#">
            SELECT 
                FORMAT(pc_pesq_data_hora, 'yyyy-MM') as mes,
                AVG((pc_pesq_comunicacao + pc_pesq_interlocucao + pc_pesq_reuniao_encerramento + 
                     pc_pesq_relatorio + pc_pesq_pos_trabalho + pc_pesq_importancia_processo) / 6.0) as media_geral
            FROM pc_pesquisas 
            WHERE RIGHT(pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            GROUP BY FORMAT(pc_pesq_data_hora, 'yyyy-MM')
            ORDER BY mes
        </cfquery>
    
        <cfset mediaGeral = (
            val(qryPesquisas.media_comunicacao) +
            val(qryPesquisas.media_interlocucao) +
            val(qryPesquisas.media_reuniao) +
            val(qryPesquisas.media_relatorio) +
            val(qryPesquisas.media_pos_trabalho) +
            val(qryPesquisas.media_importancia)
        ) / 6>
    
        <cfset var evolucaoArray = []>
        <cfloop query="qryEvolucao">
            <cfset arrayAppend(evolucaoArray, {
                "mes": mes,
                "media": NumberFormat(media_geral, "999.99")
            })>
        </cfloop>
    
        <cfquery name="rsQtdRespondidas" datasource="#application.dsn_processos#">
            SELECT COUNT(*) as total_respondidas
            FROM pc_pesquisas
            WHERE pc_org_mcu = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
        </cfquery>
        
        <!--- Obter quantidade total de processos --->
        <cfquery name="qryTotalProcessos" datasource="#application.dsn_processos#">
            SELECT COUNT(DISTINCT processos_id) as total_processos
            FROM (
                SELECT DISTINCT pc_processos.pc_processo_id as processos_id
                FROM pc_processos 
                WHERE RIGHT(pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">

                UNION

                SELECT DISTINCT processos_id
                FROM (
                    SELECT DISTINCT pc_processos.pc_processo_id as processos_id
                    FROM pc_avaliacao_orientacoes
                    INNER JOIN pc_avaliacoes 
                        ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
                    INNER JOIN pc_processos 
                        ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                    WHERE RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">

                    UNION

                    SELECT DISTINCT pc_processos.pc_processo_id
                    FROM pc_avaliacao_melhorias
                    INNER JOIN pc_avaliacoes 
                        ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
                    INNER JOIN pc_processos 
                        ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                    WHERE RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                ) AS subquery
            ) AS unificado
        </cfquery>

        <!--- Montar estrutura de retorno --->
        <cfset retorno = {
            "total": qryPesquisas.total_pesquisas,
            "totalProcessos": qryTotalProcessos.total_processos,
            "comunicacao": NumberFormat(qryPesquisas.media_comunicacao, "999.9"),
            "interlocucao": NumberFormat(qryPesquisas.media_interlocucao, "999.9"),
            "reuniao": NumberFormat(qryPesquisas.media_reuniao, "999.9"), 
            "relatorio": NumberFormat(qryPesquisas.media_relatorio, "999.9"),
            "pos_trabalho": NumberFormat(qryPesquisas.media_pos_trabalho, "999.9"),
            "importancia": NumberFormat(qryPesquisas.media_importancia, "999.9"),
            "pontualidadePercentual": NumberFormat(qryPesquisas.media_pontualidade * 100, "999.9"),
            "mediaGeral": NumberFormat(mediaGeral, "999.9"),
            "medias": [
                val(qryPesquisas.media_comunicacao),
                val(qryPesquisas.media_interlocucao),
                val(qryPesquisas.media_reuniao),
                val(qryPesquisas.media_relatorio),
                val(qryPesquisas.media_pos_trabalho),
                val(qryPesquisas.media_importancia)
            ],
            "evolucaoTemporal": evolucaoArray
        }>
    
        <cfreturn retorno>
    </cffunction>

    <cffunction name="getQuantidadeProcessosSemPesquisa" access="remote" returntype="numeric" output="false">
        <cfargument name="ano" type="string" required="true">
        <cfquery name="rsProcSemPesquisa" datasource="#application.dsn_processos#" timeout="120">
            SELECT COUNT(DISTINCT processos_id) as total_sem_pesquisa 
            FROM (
                SELECT DISTINCT pc_processos.pc_processo_id as processos_id
                FROM pc_avaliacao_orientacoes
                INNER JOIN pc_avaliacoes 
                    ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
                INNER JOIN pc_processos 
                    ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                WHERE RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                AND pc_processos.pc_processo_id NOT IN 
                (
                    SELECT pc_processo_id 
                    FROM pc_pesquisas    
                )

                UNION

                SELECT DISTINCT pc_processos.pc_processo_id
                FROM pc_avaliacao_melhorias
                INNER JOIN pc_avaliacoes 
                    ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
                INNER JOIN pc_processos 
                    ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                WHERE RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                AND pc_processos.pc_processo_id NOT IN 
                (
                    SELECT pc_processo_id 
                    FROM pc_pesquisas 
                )
            ) AS unificado
        </cfquery>

        <cfreturn rsProcSemPesquisa.total_sem_pesquisa>
    </cffunction>

    <cffunction name="formatDateForJSON" access="private" returntype="string">
        <cfargument name="dateObj" required="true" type="any">
        <cfif isDate(arguments.dateObj)>
            <cfreturn dateFormat(arguments.dateObj, "yyyy-mm-dd") & "T" & timeFormat(arguments.dateObj, "HH:mm:ss")>
        <cfelse>
            <cfreturn "">
        </cfif>
    </cffunction>

    <cffunction name="getWordCloud" access="remote" returntype="string" returnformat="json">
        <cfargument name="ano" type="string" required="true">
        <cfargument name="minFreq" type="numeric" required="false" default="2">
        <cfargument name="maxWords" type="numeric" required="false" default="100">
        
        <cfset var stopWords = "a,à,ao,aos,aquela,aquelas,aquele,aqueles,aquilo,as,às,até,com,como,da,das,de,dela,delas,dele,deles,depois,do,dos,e,é,ela,elas,ele,eles,em,entre,era,eram,éramos,essa,essas,esse,esses,esta,está,estamos,estão,estas,estava,estavam,este,esteja,estejam,estejamos,estes,esteve,estive,estivemos,estiver,estivera,estiveram,estiverem,estivermos,estou,eu,foi,fomos,for,fora,foram,fôramos,forem,formos,fosse,fossem,fôssemos,fui,há,haja,hajam,hajamos,hão,havemos,havia,hei,houve,houvemos,houver,houvera,houverá,houveram,houvéramos,houverão,houverei,houverem,houveremos,houveriam,houveríamos,houvermos,houvesse,houvessem,houvéssemos,isso,isto,já,lhe,lhes,mais,mas,me,mesmo,meu,meus,minha,minhas,muito,na,não,nas,nem,nenhum,nessa,nessas,nesta,nestas,no,nos,nós,nossa,nossas,nosso,nossos,num,numa,o,os,ou,para,pela,pelas,pelo,pelos,por,qual,quando,que,quem,são,se,seja,sejam,sejamos,sem,será,serão,serei,seremos,seria,seriam,seríamos,seu,seus,só,somos,sou,sua,suas,também,te,tem,tém,temos,tenha,tenham,tenhamos,tenho,terá,terão,terei,teremos,teria,teriam,teríamos,teu,teus,teve,tinha,tinham,tínhamos,tive,tivemos,tiver,tivera,tiveram,tivéramos,tiverem,tivermos,tivesse,tivessem,tivéssemos,toda,todas,todo,todos,tu,tua,tuas,um,uma,você,vocês,vos">
        
        <!--- Corrigida a consulta para não usar TRIM diretamente na coluna TEXT --->
        <cfquery name="qObservacoes" datasource="#application.dsn_processos#">
            SELECT pc_pesq_observacao
            FROM pc_pesquisas
            WHERE RIGHT(pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            AND pc_pesq_observacao IS NOT NULL
            AND DATALENGTH(pc_pesq_observacao) > 0
        </cfquery>
        
        <cfset var palavras = {}>
        <cfset var resultado = []>
        <cfset var maxFrequency = 0>
        
        <cfloop query="qObservacoes">
            <!--- Agora fazemos o TRIM no ColdFusion, não no SQL Server --->
            <cfset observacao = Trim(pc_pesq_observacao)>
            <cfif Len(observacao) GT 0>
                <cfset texto = REReplace(observacao, "[^\w\sáàâãéèêíìîóòôõúùûçÁÀÂÃÉÈÊÍÌÎÓÒÔÕÚÙÛÇ]", " ", "ALL")>
                <cfset texto = REReplace(texto, "\s+", " ", "ALL")>
                <cfset texto = lCase(texto)>
                
                <cfloop list="#texto#" index="palavra" delimiters=" ">
                    <cfset palavra = trim(palavra)>
                    <cfif len(palavra) GT 2 AND NOT listFindNoCase(stopWords, palavra)>
                        <cfif structKeyExists(palavras, palavra)>
                            <cfset palavras[palavra] = palavras[palavra] + 1>
                        <cfelse>
                            <cfset palavras[palavra] = 1>
                        </cfif>
                        
                        <!--- Acompanha a frequência máxima --->
                        <cfif palavras[palavra] GT maxFrequency>
                            <cfset maxFrequency = palavras[palavra]>
                        </cfif>
                    </cfif>
                </cfloop>
            </cfif>
        </cfloop>
        
        <!--- Criar um array com as palavras e suas frequências --->
        <cfset var tempArray = []>
        <cfloop collection="#palavras#" item="palavra">
            <cfif palavras[palavra] GTE arguments.minFreq>
                <cfset arrayAppend(tempArray, {
                    "text": palavra,
                    "weight": palavras[palavra],
                    "color": getColorByFrequency(palavras[palavra], maxFrequency)
                })>
            </cfif>
        </cfloop>
        
        <!--- Ordenar manualmente por peso (decrescente) --->
        <cfset sortPalavrasByWeight(tempArray)>
        
        <!--- Limitar ao máximo de palavras --->
        <cfif arrayLen(tempArray) GT arguments.maxWords>
            <cfset resultado = arraySlice(tempArray, 1, arguments.maxWords)>
        <cfelse>
            <cfset resultado = tempArray>
        </cfif>
        
        <cfreturn serializeJSON(resultado)>
    </cffunction>
    
    <cffunction name="sortPalavrasByWeight" access="private" returntype="void">
        <cfargument name="arr" type="array" required="true">
        
        <!--- Implementação manual de ordenação (bubble sort) --->
        <cfset var n = arrayLen(arguments.arr)>
        <cfset var temp = {}>
        <cfloop from="1" to="#n-1#" index="i">
            <cfloop from="1" to="#n-i#" index="j">
                <cfif arguments.arr[j].weight LT arguments.arr[j+1].weight>
                    <cfset temp = arguments.arr[j]>
                    <cfset arguments.arr[j] = arguments.arr[j+1]>
                    <cfset arguments.arr[j+1] = temp>
                </cfif>
            </cfloop>
        </cfloop>
    </cffunction>
    
    <cffunction name="getColorByFrequency" access="private" returntype="string">
        <cfargument name="frequency" type="numeric" required="true">
        <cfargument name="maxFrequency" type="numeric" required="true">
        
        <cfset var intensity = min(100, round((arguments.frequency / arguments.maxFrequency) * 100))>
        
        <cfif intensity GT 80>
            <cfreturn "##d9534f"> <!--- Bootstrap danger --->
        <cfelseif intensity GT 60>
            <cfreturn "##f0ad4e"> <!--- Bootstrap warning --->
        <cfelseif intensity GT 40>
            <cfreturn "##5bc0de"> <!--- Bootstrap info --->
        <cfelseif intensity GT 20>
            <cfreturn "##5cb85c"> <!--- Bootstrap success --->
        <cfelse>
            <cfreturn "##0275d8"> <!--- Bootstrap primary --->
        </cfif>
    </cffunction>

</cfcomponent>
