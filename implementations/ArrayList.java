package implementations;

import interfaces.List;

import java.lang.reflect.Array;
import java.util.Arrays;
import java.util.Iterator;

public class ArrayList<E> implements List<E> {
    private static final int CONSTANT_SIZE = 4;
    private Object[] elements;
    private int size;

    public ArrayList() {
        this.elements = new Object[CONSTANT_SIZE];
        this.size = 0;
    }

    @Override
    public boolean add(E element) {
        if (size == elements.length) {
            elements = setNewLength();
        }

        elements[this.size++] = element;

        return true;
    }

    @Override
    public boolean add(int index, E element) {

        if (size == elements.length) {
            elements = setNewLength();
        }



        if (index == size) {
            elements[size + 1] = element;
        } else  if (index < size) {
            for (int i = size  ; i > index; i--) {
                elements[i] = elements[i - 1];
            }
            elements[index] = element;
        }else {
            checkIndex(index);
        }
        size++;

        return true;
    }


    @Override
    public E get(int index) {
        checkIndex(index);
        return (E) elements[index];
    }

    @Override
    public E set(int index, E element) {
        checkIndex(index);
        E prevElement = (E) elements[index];
        elements[index] = element;
        return prevElement;
    }

    @Override
    public E remove(int index) {
        checkIndex(index);

        E removeElement = (E) elements[index];

        if (index == size - 1) {
            elements[index] = null;
        } else {
            elements[index] = null;
            for (int i = index; i < size - 1; i++) {
                elements[i] = elements[i + 1];
            }
        }
        size--;
        return removeElement;
    }

    @Override
    public int size() {
        return size;
    }

    @Override
    public int indexOf(E element) {
        for (int i = 0; i < elements.length; i++) {
            if (element.equals(elements[i])){
                return i;
            }
        }
        return -1;
    }

    @Override
    public boolean contains(E element) {
        for (Object o : elements) {
            if (element.equals(o)){
                return true;
            }
        }
        return false;
    }

    @Override
    public boolean isEmpty() {
        return size == 0;
    }

    @Override
    public Iterator<E> iterator() {
        return new Iterator<E>() {
            private int index = 0;
            @Override
            public boolean hasNext() {
                return this.index < size();
            }

            @Override
            public E next() {
                return get(index++);
            }
        };
    }

    private Object[] setNewLength() {
        return Arrays.copyOf(elements, size * 2);
    }

    private void checkIndex(int index) {
        if (index < 0 || index >= size) {
            throw new IndexOutOfBoundsException("Invalid index");
        }
    }
}
