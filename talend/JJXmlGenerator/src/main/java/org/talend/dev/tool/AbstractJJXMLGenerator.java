package org.talend.dev.tool;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Marshaller;
import javax.xml.namespace.QName;

import org.talend.components.maven.legacy.model.COMPONENT;

public abstract class AbstractJJXMLGenerator {

    protected abstract COMPONENT create();

    public final void write(final File output) throws Exception {
         final JAXBContext modelContext = JAXBContext.newInstance(COMPONENT.class);
         final Marshaller marshaller = modelContext.createMarshaller();
         marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
         try (final OutputStream stream = new BufferedOutputStream(new FileOutputStream(output))) {
             marshaller.marshal(new JAXBElement<>(new QName("COMPONENT"), COMPONENT.class, create()), stream);
         }
     }
    
    
}
