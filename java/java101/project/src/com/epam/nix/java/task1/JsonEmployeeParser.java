package com.epam.nix.java.task1;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.Reader;

public class JsonEmployeeParser {

    public static void main(String[] args) {

        if (args.length == 0) {
            throw new IllegalArgumentException("Json file path is not specified");
        }

        String jsonFilePath = args[0];

        Gson gson = new GsonBuilder().create();
        Reader reader;
        try {
            reader = new FileReader(jsonFilePath);
            Employee[] employees = gson.fromJson(reader, Employee[].class);
            printEmployees(employees);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    private static void printEmployees(Employee[] employees) {
        for (int i = 0; i < employees.length; i++) {
            Employee employee = employees[i];
            System.out.println("Employee number:" + (i + 1));
            System.out.println("Name:" + employee.getName());
            System.out.println("Surname:" + employee.getSurname());
            System.out.println("Age:" + employee.getAge());
            System.out.println("Department:" + employee.getDepartment());
        }
    }

}
