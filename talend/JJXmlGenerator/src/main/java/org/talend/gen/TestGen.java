package org.talend.gen;

import java.io.File;

import org.talend.components.maven.legacy.model.COMPONENT;
import org.talend.components.maven.legacy.model.CONNECTOR;
import org.talend.components.maven.legacy.model.PARAMETER;
import org.talend.components.maven.legacy.model.PARAMETERS;
import org.talend.dev.tool.AbstractJJXMLGenerator;

public class TestGen {

    public static void main(String[] args) {
        TestCompo tc = new TestCompo();
        try {
            tc.write(new File("./tTestCompo_java.xml"));
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
    
    private final static class TestCompo extends AbstractJJXMLGenerator {

        @Override
        protected COMPONENT create() {
            COMPONENT c = new COMPONENT();
            
            PARAMETERS params = new PARAMETERS();
            PARAMETER p = new PARAMETER();
            p.setNAME("MyName");
            p.setFIELD("TEXT");
            params.getPARAMETER().add(p);
            
            c.setPARAMETERS(params);
            
            CONNECTOR conn = new CONNECTOR();
            conn.setNOTSHOWIF("");
            
            return c;
        }
        
    }

}
