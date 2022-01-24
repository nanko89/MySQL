package implementations;

import interfaces.LinkedList;

import java.util.Iterator;

public class SinglyLinkedList<E> implements LinkedList<E> {

    private static final class Node<E>{
        private E element;
        private Node<E> next;


        public Node(E element) {
            this.element = element;
        }
    }

    private Node<E> head;
    private int size;

    public SinglyLinkedList() {
        this.size = 0;
        this.head = null;
    }

    @Override
    public void addFirst(E element) {
        Node<E> current = new Node<>(element);

        current.next = head;
        head = current;
        size++;
    }

    @Override
    public void addLast(E element) {
        Node<E> lastElement = new Node<>(element);

        if (head == null){
            head = lastElement;

        }else {
           Node<E> last = head;
           while (last.next != null){
               last =  last.next;
           }
           last.next = lastElement;
        }
        size++;
    }

    @Override
    public E removeFirst() {
        isEmptyList();

        E removed = head.element;
        head = head.next;
        size --;
        return removed;
    }

    private void isEmptyList() {
        if (head == null){
            throw new IllegalStateException("LinkedList is empty");
        }
    }

    @Override
    public E removeLast() {
        isEmptyList();

        Node <E> preLast = head;
        Node <E> last = head.next;
        while (last.next != null){
            preLast = last;
            last = last.next;
        }
       preLast.next = null;
        size--;

        return  last.element;
    }

    @Override
    public E getFirst() {
        isEmptyList();
        return head.element;
    }

    @Override
    public E getLast() {
        isEmptyList();
        Node<E> last = head;
        while (last.next != null){
            last = last.next;
        }

        return last.element;
    }

    @Override
    public int size() {
        return size;
    }

    @Override
    public boolean isEmpty() {
        return head == null;
    }

    @Override
    public Iterator<E> iterator() {
        return null;
    }
}
