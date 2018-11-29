@page { 
    size: 8.5in 11in; /* US Letter width and height */ 
    margin: 25px 50px 25px 50px;
}

body {
    font-family: sans-serif, Arial Unicode MS;
    font-size: 8pt;
    margin: 25px 50px 25px 50px;
}

hr {
	border: 0;
    height: 1px;    
    background: black;
}

.toprightcorner {
    top:20px;
    right:0;
    text-align: right;
    padding-right:20pt;
    position: relative;
}

div.bincHeader {
	height: 70px;    
}

div.bincHeader h1 {
    font-size: 16pt;
}


b {
    font-weight: bolder;
}

td.leftBorder {
    border-left: solid black 2px;
    padding-left: 4px;
}

td.numberColumn {
    text-align: right;
}

div.salesHeader {
    padding-top: 10px;
    height: 35px;
	border-bottom: solid black 2px;
	vertical-align: bottom;    
    font-weight: bold;
    margin-bottom: 16px;
}

table.salesHeader {
    margin-bottom: 50px;
}

table.salesHeader td {
    line-height: 1.4em;
}

h1 {
    font-size: 16pt;
    margin: 0px 0px 2px 0px;
}

table {
    width: 100%;
    border-collapse: collapse;
}

td {
    text-align: left;
    vertical-align: top;
    padding: 0;
    margin: 0;
    line-height: 1.1em;
}

h2 {
    font-weight: bold;
    font-size: 10pt;
    margin: 0px 0px 0px 0px;
    line-height: 1.4em;
}

table.patientDataSheetList {
    border: solid black 1px;
    border-collapse: collapse;
}

table.patientDataSheetList th {
    border: none;
}

table.patientDataSheetList td {
    border: solid black 1px;
    padding: 1px;
}

th {
    font-weight: bold;
}

table.salesList {
    border: solid black 1px;
    margin-top: 20px;
    margin-bottom: 20px;
}

table.salesList th {
    padding: 2px 7px 2px 7px;
    border: solid black 1px;
}

table.salesList td {
    padding: 2px 7px 2px 7px;
    border: solid black 1px;
}

table.salesList tr {
    height: 13px;
}

div.sales_footerdiv_left {
	display : inline-block;
	width : 40%;
	margin-top : .8cm;
}

div.sales_footerdiv_middle {
	display : inline-block;
	width : 20%;
	bottom : 0;
}

div.sales_footerdiv_right {
	display : inline-block;
	float : right;
    margin-top: 16px;
}


div.termConDiv_leftdiv {
	max-width : 47%;
	display : inline-block;
	vertical-align : top;
	text-align : justify;
	text-justify : inter-word;
	padding-right : .5cm;
	color : #404040;	
}

div.termConDiv_rightdiv {
	display : inline-block;
	vertical-align : top;
	padding-left : .5cm;
	text-align : justify;
	text-justify : inter-word;
	max-width : 46%;
	color : #404040;
}


table.salesFooter {
    margin-top: 60px;
}

div.page-break {
    page-break-before: always;
    page-break-after: always;
}

table.pacemakerReportList {
    margin-bottom: 6px;
}

table.pacemakerReportList th {
    background: #E8E8E8;
    border: solid #E8E8E8 1px;
    font-weight: bold;
    text-align: center;
}

table.pacemakerReportList td {
 	border: solid black 1px;
    padding-left: 1px 2px 1px 2px;
}

h2.oosTitle {
    margin-top: 16px;
    margin-bottom: 8px;
}

h2.oosTitle span {
    color: white;
    background: black;
    min-height: 14px;
    min-width: 50px;
}    

table.oosTable {
    border: solid black 1px;
}

table.oosTable th {
    vertical-align: top;
    font-size: 8pt;
    border-top: solid black 1px;
    font-weight: normal;
}

table.oosTable th:first-child {
    border-left: solid black 1px;
}

table.oosTable td:first-child {
    border-left: solid black 1px;
}

table.oosTable td {
    border-bottom: solid black 1px;
}

.borderRight {
    border-right: solid black 1px;
}

.borderTop {
    border-top: solid black 1px;
}

.broderLeft {
    border-left: solid black 1px;
}


/* Temporary Patient ID card */

h3 {
    font-size: 8.5pt;
    color: #587A93;
}



table.tpid {
    margin-top: 6px;
}

table.tpid th {
    border-top: solid black 0.5px;
    text-transform: uppercase;
    font-weight: normal;
    padding-bottom: 4px;
    vertical-align: top;
    font-size: 6pt;
}

table.tpid td {
    text-transform: uppercase;
    vertical-align: bottom;
    padding-bottom: 2px;
    font-size: 8pt;
}

div.tpidtitle {
    font-size: 16pt;
    line-height: 20pt;
    color: #587A93;
    text-align: center;
    margin-top: 12px;
    margin-bottom: 12px;
}

div.tpidlogo {
    float: right;
    clear: right;
    color: #587A93;
}


/* MDRF */
.important {
    font-weight: bold;
    text-decoration: underline;
}

div.mdrfHeader {
    float: left; 
    clear: left; 
    width: 460px;
    min-height: 20px;
    font-size: 6pt;
    margin-left: 32px;
}

div.mdrfHeader h1 {
    font-size: 14pt;
}

div.mdrfLogo {
    float: left;
    padding: 0;
    font-size: 8pt;
    margin-right: -28px;
}

div.mdrfLogo img {
    margin-left: -37px;
}

body.mdrf {
    margin: 0 12px 0 0;
}

hr.light {
    background: #E0E0E0;
    height: 2px;
}

div.mdrfBlock {
    float: left;
    margin-left: 8px;
    height: 1.2em;
    margin-bottom: 4px;
}

div.underline {
    border-bottom: solid black 0.5px;
    padding-left: 8px;
}

td.mdrfBlock {
    border-top: solid #E0E0E0 2px;
    padding: 8px 0 4px 0;
    vertical-align: middle;
}

.lighter  {
    font-size: 0.8em;
    color: #808080;
}

table {
    margin-top: 8px;
}

table.mdrfleads {
    margin-top: 20px;
}

table.mdrfleads th,table.mdrfleads td {
    padding: 1px 2px 1px 2px;
    vertical-align: middle;
    border: solid #E0E0E0 0.5px;
}

table.mdrfleads th {
    text-align: center;
}

table.mdrfleads td {
    text-align: right;
}

div.data {
    border-bottom: solid black 0.5px;
    display: inline-block;
    padding: 0 3px 1px 3px;
    margin-bottom: 3px;
}

table div.data {
    text-align: right;
}


table.mdrfphysicians div.data {
    text-align: left;
}

table.mdrfphysicians {
    margin-top: 14px;
}

table.mdrfphysicians td, table.mdrfphysicians th{
    padding-top: 6px;
}

div.mdrfproductlabel {
    height: 13mm;
}

div.left {
    float: left;
    clear:left;
}

div.right {
    float: right;
    clear: right;
}

table.mdrfphysicians th {
    text-align: center;
}

div.mdrfoos {
    border: solid black 2px;
    margin-top: 14px;
    margin-bottom: 16px;
    padding: -8px 4px 20px;
    display: block;
}

table.mdrfoos {
    margin: 4px;
}

table.mdrfoos td {
    padding: 2px;
}








