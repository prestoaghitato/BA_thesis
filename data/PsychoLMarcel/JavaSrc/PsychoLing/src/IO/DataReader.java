package IO;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

import core.Sequence;
import core.SequenceSet;
import util.ArrayUtil;
import util.PrintUtil;

public class DataReader {
	
	public ArrayList<ArrayList<String[]>> readRoughtData(String dirURL)
	{
		ArrayList<ArrayList<String[]>> ret_LL = new ArrayList<>();
		
		File dir = new File(dirURL);
		
		String[] files = dir.list();
		
		for(int i=0; i< files.length; i++)
		{
			ArrayList<String[]> ret_L = new ArrayList<>();
			
			FileReader fr;
			BufferedReader br;
			
			try {
				fr = new FileReader(new File(dirURL + "\\" + files[i]));
				br = new BufferedReader(fr);
				
				String line = null;
				String[] split = null;
				
				while((line = br.readLine()) != null)
				{
					split = line.trim().replaceAll("\\s\\s"," ").toLowerCase().split("\\s");
				
					ret_L.add(split);
				}
				
				ret_LL.add(ret_L);
				
				br.close();
				fr.close();
				
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}				
		return ret_LL;
	}
	
	public String[] cleanLine(String[] line)
	{
		String[] cLine = new String[3];
		
		StringBuffer label = new StringBuffer();
		
		boolean isDouble = true;
		boolean isFirstDouble = true;
		boolean isFirstLabel = true;
		
		for(int i=0; i<line.length; i++)
		{
			isDouble = true;
			
			try{
				Double.parseDouble(line[i]);		
			}
			catch(NumberFormatException e)
			{
				isDouble = false;
			}
			
			if(isDouble)
			{
				if(isFirstDouble) 	{cLine[1] = line[i]; isFirstDouble = false; isFirstLabel = false;}
				else				cLine[2] = line[i];
			}
			else
			{
				if(isFirstLabel) 
				{
					if(i == 0) label.append(line[i]);
					else		label.append("_" + line[i]);
				}
				else if(label.toString().equals("infant"))
				{
					label.append("_" + line[i]);
				}
			}
		}
		cLine[0] = label.toString();
		
		return cLine;
	}
	
	public SequenceSet extractSequences(ArrayList<ArrayList<String[]>> rawData)
	{
		SequenceSet ret_V = new SequenceSet();
		
		ArrayList<String[]> rawSequence;
		
		for(ArrayList<String[]> a_L: rawData)
		{
			rawSequence = new ArrayList<>();
			
			for(String[] line: a_L)
			{
				rawSequence.add(cleanLine(line));
			}
			
			ret_V.buildSequence(rawSequence);
		}
		
		return ret_V;
	}

}
